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
      self.activities =  Enumeration::get_values('ACTI').collect(&:id)
    end

    unless options[:users].nil?
      self.users = options[:users].collect { |u| User.find(u.to_i) }
    else
      self.users = User.find(:all)
    end

    self.date_from = options[:date_from] || 1.month.ago.to_date
    self.date_to = options[:date_to] || Date.today.to_s
    self.billing_status = options[:billing_status] || BillingStatus.names.map { |n| n.to_s }
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
    return ['invoiced_on >= (:from) AND invoiced_on <= (:to) AND billing_status IN (:billing_status) AND project_id IN (:projects)',
            {
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
