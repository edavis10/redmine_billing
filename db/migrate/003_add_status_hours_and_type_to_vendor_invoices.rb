class AddStatusHoursAndTypeToVendorInvoices < ActiveRecord::Migration
  def self.up
    add_column :vendor_invoices, :billing_status, :string
    add_column :vendor_invoices, :hours, :decimal, :precision => 15, :scale => 2
    add_column :vendor_invoices, :type, :string
  end

  def self.down
    remove_column :vendor_invoices, :billing_status
    remove_column :vendor_invoices, :hours
    remove_column :vendor_invoices, :type
  end
end
