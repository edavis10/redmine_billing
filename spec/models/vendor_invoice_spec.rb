require File.dirname(__FILE__) + '/../spec_helper'

module VendorInvoiceSpecHelper
  # TODO: Semi-Duplicated
  def vendor_invoice_object_factory(id, options = { })
    object_options = { 
      :id => id,
      :number => '9000',
      :invoiced_on => Date.today
    }.merge(options)
    
    vendor_invoice = VendorInvoice.new object_options
    return vendor_invoice
  end
end

describe VendorInvoice, 'when saving' do
  include VendorInvoiceSpecHelper
  
  it 'should set the type to fixed if amount is present' do
    vendor_invoice = vendor_invoice_object_factory(1,
                                                   {
                                                     :amount => 200.00,
                                                     :billing_status => 'unbilled'})

    vendor_invoice.save.should eql(true)
    vendor_invoice.reload
    vendor_invoice.billing_type.should eql('fixed')
  end

  it 'should set the type to hourly if amount is absent' do
    vendor_invoice = vendor_invoice_object_factory(1,
                                                   {
                                                     :amount => nil,
                                                     :billing_status => 'unbilled'})

    vendor_invoice.save.should eql(true)
    vendor_invoice.reload
    vendor_invoice.billing_type.should eql('hourly')

  end
end
