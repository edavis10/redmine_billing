class ConvertVendorInvoicesToSti < ActiveRecord::Migration
  
  # Store classes in the migration just in case they are changed later
  class VendorInvoice < ActiveRecord::Base; end
  class HourlyVendorInvoice < VendorInvoice; end
  class FixedVendorInvoice < VendorInvoice;  end
  
  def self.up
    add_column :vendor_invoices, :type, :string
 
    VendorInvoice.reset_column_information
    
    VendorInvoice.transaction do
      VendorInvoice.find(:all).each do |invoice|
        if invoice.billing_type == 'fixed'
          invoice.update_attribute(:type, 'FixedVendorInvoice')
        else
          invoice.update_attribute(:type, 'HourlyVendorInvoice')
        end
      end
    end
  end

  def self.down
    remove_column :vendor_invoices, :type
  end
end
