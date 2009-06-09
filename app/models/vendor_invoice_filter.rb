class VendorInvoiceFilter
  attr_accessor :date_from
  attr_accessor :date_to
  attr_accessor :projects
  attr_accessor :activities
  attr_accessor :users
  attr_accessor :vendor_invoices
  attr_accessor :allowed_projects
  attr_accessor :billing_status
  
  def initialize(options = { })
    self.vendor_invoices = options[:vendor_invoices] || { }
    self.projects = [ ]
    self.allowed_projects = options[:allowed_projects] || [ ]

    unless options[:activities].nil?
      self.activities = options[:activities].collect { |a| a.to_i }
    else
      self.activities = BillingCompatibility::Enumeration.activities.collect(&:id)
    end

    unless options[:users].nil?
      self.users = options[:users].collect { |u| User.find(u.to_i) }
    else
      self.users = User.find(:all)
    end

    self.date_from = options[:date_from] || 1.month.ago.to_date
    self.date_to = options[:date_to] || Date.today
    self.billing_status = options[:billing_status] || BillingStatus.names.map { |n| n.to_s }
  end
  
  def period=(period)
    # Stolen from the TimelogController
    case period.to_s
    when 'today'
      self.date_from = self.date_to = Date.today
    when 'yesterday'
      self.date_from = self.date_to = Date.today - 1
    when 'current_week' # Mon -> Sun
      self.date_from = Date.today - (Date.today.cwday - 1)%7
      self.date_to = self.date_from + 6
    when 'last_week'
      self.date_from = Date.today - 7 - (Date.today.cwday - 1)%7
      self.date_to = self.date_from + 6
    when '7_days'
      self.date_from = Date.today - 7
      self.date_to = Date.today
    when 'current_month'
      self.date_from = Date.civil(Date.today.year, Date.today.month, 1)
      self.date_to = (self.date_from >> 1) - 1
    when 'last_month'
      self.date_from = Date.civil(Date.today.year, Date.today.month, 1) << 1
      self.date_to = (self.date_from >> 1) - 1
    when '30_days'
      self.date_from = Date.today - 30
      self.date_to = Date.today
    when 'current_year'
      self.date_from = Date.civil(Date.today.year, 1, 1)
      self.date_to = Date.civil(Date.today.year, 12, 31)
    when 'all'
      self.date_from = self.date_to = nil
    end
    self
  end
  
  def filter!
    self.vendor_invoices = { }
    
    self.users.each do |user|

      if User.current.admin?
        # Administrators can see all vendor invoices
        invoices = vendor_invoices_for_user(user)
      elsif User.current == user
        # Users with permission to see their own vendor invoices
        invoices = vendor_invoices_for_user(user)
      else
        # Nothing
      end

      self.vendor_invoices[user] = invoices
      self.vendor_invoices[user] ||= []
    end
  end
  
  def conditions_for_user(user)
    # Allow nil from and to values to represent 'all'
    if self.date_from && self.date_to
      date_conditions = "invoiced_on >= (:from) AND invoiced_on <= (:to) AND "
    else
      date_conditions = ""
    end

    return [date_conditions + " billing_status IN (:billing_status) AND " +
            # Check project field for fixed billing_types
            "(type = (:fixed) AND #{VendorInvoice.table_name}.project_id IN (:projects)" +
            # Check time_entry fields for hourly types
            "OR (#{TimeEntry.table_name}.project_id IN (:projects) AND activity_id IN (:activities)))",
            {
              :fixed => FixedVendorInvoice.name,
              :from => self.date_from,
              :to => self.date_to,
              :billing_status => self.billing_status,
              :projects => self.projects,
              :activities => self.activities
            }
           ]
  end
  
  private
  def vendor_invoices_for_user(user)
    user.vendor_invoices.find(:all, :conditions => conditions_for_user(user), :include => :time_entries)
  end
end
