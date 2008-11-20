require File.dirname(__FILE__) + '/../spec_helper'

module FixedVendorInvoiceSpecHelper
end

describe FixedVendorInvoice, 'humanize' do
  it 'should return "Fixed"' do
    FixedVendorInvoice.new.humanize.should eql('Fixed')
  end
end
