class VendorInvoice < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :time_entries
  
  validates_presence_of :number
  validates_presence_of :invoiced_on
  validates_presence_of :billing_status
  
  before_save :set_billing_type
  
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
end
