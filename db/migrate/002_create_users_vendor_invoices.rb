class CreateUsersVendorInvoices < ActiveRecord::Migration
  def self.up
    create_table :users_vendor_invoices, :id => false do |t|
      t.column :user_id, :integer, :null => false
      t.column :vendor_invoice_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :users_vendor_invoices
  end
end
