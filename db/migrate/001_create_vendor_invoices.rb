class CreateVendorInvoices < ActiveRecord::Migration
  def self.up
    create_table :vendor_invoices do |t|
      t.column :number, :string
      t.column :invoiced_on, :date
      t.column :comment, :text
      t.column :amount, :decimal, :precision => 15, :scale => 2
    end
  end

  def self.down
    drop_table :vendor_invoices
  end
end
