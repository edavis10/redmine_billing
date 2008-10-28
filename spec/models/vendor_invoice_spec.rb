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
  
  def time_entry_mock_factory(id, options = { })
    object_options = { 
      :id => id,
      :to_param => id.to_s,
      :hours => 1,
      :issue_id => 10,
      :user_id => 2,
      :activity_id => 3,
      :spent_on => Date.today
    }.merge(options)
    
    return mock_model(TimeEntry, object_options)
    
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

describe VendorInvoice, 'hours' do
  include VendorInvoiceSpecHelper
  
  it 'should return 0 if there are no time entries' do
    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:time_entries).and_return([])
    
    vendor_invoice.hours.should eql(0)
  end
  
  it 'should return the sum of time entries if not passed a user' do
    @user = mock_model(User, :id => 2)
    @another_user = mock_model(User, :id => 3)
    vendor_invoice = vendor_invoice_object_factory(1)
    time_entry_one = time_entry_mock_factory(1, { :user => @user, :hours => 3})
    time_entry_two = time_entry_mock_factory(1, { :user => @user, :hours => 3})
    time_entry_three = time_entry_mock_factory(1, { :user => @another_user, :hours => 3})
    time_entries = [time_entry_one, time_entry_two, time_entry_three]
    
    vendor_invoice.should_receive(:time_entries).twice.and_return(time_entries)
    
    vendor_invoice.hours.should eql(9)
  end
  
  it 'should return the sum of a specific users time entries when passed a user' do
    @user = mock_model(User, :id => 2)
    @another_user = mock_model(User, :id => 3)
    vendor_invoice = vendor_invoice_object_factory(1)
    time_entry_one = time_entry_mock_factory(1, { :user => @user, :hours => 3})
    time_entry_two = time_entry_mock_factory(1, { :user => @user, :hours => 3})
    time_entry_three = time_entry_mock_factory(1, { :user => @another_user, :hours => 3})
    time_entries = [time_entry_one, time_entry_two, time_entry_three]
    
    vendor_invoice.should_receive(:time_entries).twice.and_return(time_entries)
    
    vendor_invoice.hours(@user).should eql(6)
  end
  
end

describe VendorInvoice, 'user_names' do
  include VendorInvoiceSpecHelper
  
  it 'should return an empty string if there are no users' do
    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:users).and_return([])
    vendor_invoice.user_names.should eql('')
    
  end

  it 'should return a comma separated string listing each user' do
    @user = mock_model(User, :id => 1)
    @user.should_receive(:name).and_return("Joe User")
    @user_two = mock_model(User, :id => 2)
    @user_two.should_receive(:name).and_return("Jane User")
    
    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:users).and_return([@user, @user_two])
    vendor_invoice.user_names.should eql('Joe User, Jane User')
  end
end
