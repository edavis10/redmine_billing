class VendorInvoice < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :time_entries
  
  validates_presence_of :number
  validates_presence_of :invoiced_on
  validates_presence_of :billing_status
  
  before_save :set_billing_type
  
  # A VendorInvoice is the billing_type of fixed if it has amount
  def set_billing_type
    if !self.read_attribute(:amount).nil? && self.read_attribute(:amount) > 0
      self.write_attribute(:billing_type, 'fixed')
    else
      self.write_attribute(:billing_type, 'hourly')
    end

    return true
  end
  
  def billing_status_id
    BillingStatus.find_by_id(self.billing_status)
  end
  
  def fixed?
    return self.read_attribute(:billing_type) == "fixed"
  end

  def hourly?
    return self.read_attribute(:billing_type) == "hourly"
  end
  
  def open?
    self.billing_status == "paid"
  end

  # Returns the hours logged to the vendor invoice
  # Optionally only shows ones logged by the +user+
  def hours(user=nil)
    return 0 if self.time_entries.size <= 0
    if user.nil?
      return self.time_entries.collect(&:hours).sum
    else
      return self.time_entries.collect { |te| te.user == user ? te.hours : 0}.sum
    end
    
  end
  
  def amount_for_user(user=nil)
    return 0 if self.time_entries.size <= 0
    amount = 0
    self.time_entries.each do |te|
      if user.nil? || te.user == user
        mem = Member.find_by_user_id_and_project_id(te.user_id, te.project_id)
        if !mem.nil? && mem.respond_to?(:rate) && !mem.rate.nil?
          amount += mem.rate * te.hours
        end
      end
    end

    return amount
  end
  
  def user_names
    self.users.collect(&:name).join(", ")
  end
  
  # OPTIMIZE: Try to use less SQL queries and less AR object construction
  def self.search_allowed(user, term)
    
    if user.admin?
      # Admins can see all
      conditions = [ "LOWER(number) LIKE (?)", '%' + term + '%' ]
      return self.find(:all, :conditions => conditions)
    else
      invoices = []
      # All fixed bids
      invoices << self.find(:all, :conditions => [ "LOWER(number) LIKE (?) AND billing_type = ?", '%' + term + '%', 'fixed'])
      # All hourly where ...
      hourly = self.find(:all, :conditions => [ "LOWER(number) LIKE (?) AND billing_type = ?", '%' + term + '%', 'hourly'])
      hourly.each do |invoice|
        if invoice.users.include?(user)
          # ... the user is the invoice owner or ...
          invoices << invoice
        end

        if !invoice.time_entries.empty?
          projects = invoice.time_entries.collect(&:project).uniq
          projects.each do |project|
            if user.allowed_to?(:all_invoices_on_project, project)
              # ... they are on the project with the permission to see all invoices
              invoices << invoice
            end
          end
        end
      end
      
      return invoices.flatten.uniq
    end
    
  end
end
