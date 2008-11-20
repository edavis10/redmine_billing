class FixedVendorInvoice < VendorInvoice
  validates_presence_of :project_id, :message => "can't be blank on Fixed Rate Invoices"
  validates_presence_of :amount, :message => "can't be blank on Fixed Rate Invoices"
end
