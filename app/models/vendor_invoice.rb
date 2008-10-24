class VendorInvoice < ActiveRecord::Base
  has_and_belongs_to_many :users
  
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
end
