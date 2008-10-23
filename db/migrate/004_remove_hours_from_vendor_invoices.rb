class RemoveHoursFromVendorInvoices < ActiveRecord::Migration
  def self.up
    remove_column :vendor_invoices, :hours

  end

  def self.down
    add_column :vendor_invoices, :hours, :decimal, :precision => 15, :scale => 2
  end
end
