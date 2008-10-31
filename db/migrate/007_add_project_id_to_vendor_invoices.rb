class AddProjectIdToVendorInvoices < ActiveRecord::Migration
  def self.up
    add_column :vendor_invoices, :project_id, :integer
  end

  def self.down
    remove_column :vendor_invoices, :project_id
  end
end
