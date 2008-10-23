class RenameTypeToBillingTypeOnVendorInvoices < ActiveRecord::Migration
  def self.up
    add_column :vendor_invoices, :billing_type, :string
    remove_column :vendor_invoices, :type
    
  end

  def self.down
    add_column :vendor_invoices, :type, :string
    remove_column :vendor_invoices, :billing_type
  end
end
