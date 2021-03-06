class VendorInvoice < ActiveRecord::Base
  unloadable
  has_and_belongs_to_many :users
  has_many :time_entries
  belongs_to :project
  
  validates_presence_of :number
  validates_presence_of :invoiced_on
  validates_presence_of :billing_status

  def initialize(params={})
    super(params)
    self.invoiced_on ||= Date.today
  end
  
  def billing_type
    ActiveSupport::Deprecation.warn('VendorInvoice#billing_type should be replaced with STI classes.')
    self.read_attribute(:billing_type)
  end
  
  def billing_status_id
    BillingStatus.find_by_id(self.billing_status)
  end
  
  def fixed?
    return self.class == FixedVendorInvoice
  end

  def hourly?
    return self.class == HourlyVendorInvoice
  end
  
  def open?
    self.billing_status == "paid"
  end
  
  def humanize
    ActiveSupport::Inflector.humanize(self.class.to_s.gsub(/VendorInvoice/,''))
  end
  
  # Returns the sum of hours on TimeEntries for this VendorInvoice that are missing
  # a cost value.
  def hours_without_rates
    self.time_entries_without_rates.collect(&:hours).sum
  end

  # Returns the TimeEntries without a cost value.
  def time_entries_without_rates
    self.time_entries.collect {|te| te.cost <= 0 ? te : nil}.compact
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
    return self.time_entries.select do |time_entry|
      user.nil? || time_entry.user == user
    end.collect(&:cost).compact.sum
  end
  
  def user_names
    self.users.collect(&:name).join(", ")
  end
  
  def self.allowed_to_use_accounts_payable?(user)
    return user.allowed_to?(:use_accounts_payable, nil, { :global => true })
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
      invoices << self.find(:all, :conditions => [ "LOWER(number) LIKE (?) AND type = ?", '%' + term + '%', FixedVendorInvoice.name])
      # All hourly where ...
      hourly = self.find(:all, :conditions => [ "LOWER(number) LIKE (?) AND type = ?", '%' + term + '%', HourlyVendorInvoice.name])
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
