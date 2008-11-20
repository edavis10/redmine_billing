require File.dirname(__FILE__) + '/../spec_helper'

module HourlyVendorInvoiceSpecHelper
end

describe HourlyVendorInvoice, 'humanize' do
  it 'should return "Hourly"' do
    HourlyVendorInvoice.new.humanize.should eql('Hourly')
  end
end
