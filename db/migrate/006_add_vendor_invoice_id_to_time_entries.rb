class AddVendorInvoiceIdToTimeEntries < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :vendor_invoice_id, :integer
  end

  def self.down
    remove_column :time_entries, :vendor_invoice_id
  end
end
