require File.dirname(__FILE__) + '/../spec_helper'

module HourlyVendorInvoiceSpecHelper
end

describe HourlyVendorInvoice, 'humanize' do
  it 'should return "Hourly"' do
    HourlyVendorInvoice.new.humanize.should eql('Hourly')
  end
end

describe HourlyVendorInvoice, 'set_default_user' do
  it 'should do nothing if there are no TimeEntries' do
    ve = HourlyVendorInvoice.new
    ve.set_default_user
    ve.user_ids.should be_empty
  end

  it 'should do nothing if the user_id is already set' do
    time_entry_one = mock_model(TimeEntry, :spent_on => Date.today, :user_id => 1)
    time_entry_two = mock_model(TimeEntry, :spent_on => Date.yesterday, :user_id => 2)
    
    ve = HourlyVendorInvoice.new(:user_ids => [1])
    ve.time_entries = [time_entry_one, time_entry_two]
    ve.set_default_user
    ve.user_ids.size.should eql(1)
    ve.user_ids.should include(1)
  end

  it 'should set the user_id based on the oldest assigned TimeEntry' do
    time_entry_one = mock_model(TimeEntry, :spent_on => Date.today, :user_id => 1)
    time_entry_two = mock_model(TimeEntry, :spent_on => Date.yesterday, :user_id => 2)

    ve = HourlyVendorInvoice.new
    ve.time_entries = [time_entry_one, time_entry_two]
    ve.should_receive(:user_ids=).with([2])
    ve.set_default_user
  end

end
