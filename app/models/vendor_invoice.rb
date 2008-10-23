class VendorInvoice < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  validates_presence_of :number
  validates_presence_of :invoiced_on
  validates_presence_of :billing_status
end
