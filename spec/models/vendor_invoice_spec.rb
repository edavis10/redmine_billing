require File.dirname(__FILE__) + '/../spec_helper'

module VendorInvoiceSpecHelper
  # TODO: Semi-Duplicated
  def vendor_invoice_object_factory(id, options = { })
    object_options = { 
      :id => id,
      :number => '9000',
      :invoiced_on => Date.today,
      :project_id => nil
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

describe VendorInvoice, 'fixed?' do
  it 'should be false if a generic VendorInvoice is created' do
    VendorInvoice.new.fixed?.should be_false
  end

  it 'should be true if a FixedVendorInvoice is created' do
    FixedVendorInvoice.new.fixed?.should be_true
  end

  it 'should be false if a HourlyVendorInvoice is created' do
    HourlyVendorInvoice.new.fixed?.should be_false
  end
end

describe VendorInvoice, 'hourly?' do
  it 'should be false if a generic VendorInvoice is created' do
    VendorInvoice.new.hourly?.should be_false
  end

  it 'should be false if a FixedVendorInvoice is created' do
    FixedVendorInvoice.new.hourly?.should be_false
  end

  it 'should be true if a HourlyVendorInvoice is created' do
    HourlyVendorInvoice.new.hourly?.should be_true
  end
end

describe VendorInvoice, 'open?' do
  it 'should be true if the billing_status is paid' do
    VendorInvoice.new({ :billing_status => 'paid'}).open?.should be_true
  end

  it 'should be true if the billing_status is not paid' do
    VendorInvoice.new({ :billing_status => 'hold' }).open?.should be_false
  end
end

describe VendorInvoice, 'humanize' do
  it 'should return the an empty string' do
    VendorInvoice.new.humanize.should eql('')
  end
end

describe VendorInvoice, 'amount_for_user with no parameter' do
  include VendorInvoiceSpecHelper

  it 'should return 0 if there are no time entries' do
    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:time_entries).and_return([])
    
    vendor_invoice.amount_for_user.should eql(0)
  end
  
  it 'should return the total of all the cost of the time_entries' do
    @user = mock_model(User, :id => 1, :to_param => 1)
    @project = mock_model(Project, :id => 10)
    time_entry_one = time_entry_mock_factory(1, { :user_id => @user.id, :hours => 3, :project_id => @project.id, :cost => 3000.0})
    time_entry_two = time_entry_mock_factory(2, { :user_id => @user.id, :hours => 10, :project_id => @project.id, :cost => 10000.0})

    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:time_entries).at_least(:once).and_return([time_entry_one, time_entry_two])
    
    vendor_invoice.amount_for_user.should eql(13000.0)

  end
  
  it "should return 0 if a Time Entry doesn't have a cost" do
    @user = mock_model(User, :id => 1, :to_param => 1)
    @project = mock_model(Project, :id => 10)
    time_entry_one = time_entry_mock_factory(1, { :user_id => @user.id, :hours => 3, :project_id => @project.id, :cost => nil})
    time_entry_two = time_entry_mock_factory(2, { :user_id => @user.id, :hours => 10, :project_id => @project.id, :cost => nil})

    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:time_entries).at_least(:once).and_return([time_entry_one, time_entry_two])
    
    vendor_invoice.amount_for_user.should eql(0)

  end
end

describe VendorInvoice, 'amount_for_user with a user parameter' do
  include VendorInvoiceSpecHelper

  before(:each) do
    @user = mock_model(User, :id => 1, :to_param => 1)
  end
  
  it 'should return the total cost of all the Time Entries for that user' do
    @user = mock_model(User, :id => 1, :to_param => 1)
    @user2 = mock_model(User, :id => 2, :to_param => 2)
    @project = mock_model(Project, :id => 10)
    time_entry_one = time_entry_mock_factory(1, { :user => @user, :user_id => @user.id, :hours => 3, :project_id => @project.id, :cost => 3000.0})
    time_entry_two = time_entry_mock_factory(2, { :user => @user2, :user_id => @user2.id, :hours => 10, :project_id => @project.id, :cost => 50.0})

    vendor_invoice = vendor_invoice_object_factory(1)
    vendor_invoice.should_receive(:time_entries).at_least(:once).and_return([time_entry_one, time_entry_two])
    
    vendor_invoice.amount_for_user(@user).should eql(3000.0)

  end
end

describe VendorInvoice, "#time_entries_without_rates" do
  include VendorInvoiceSpecHelper

  it 'should be empty if there are no time entries' do
    vendor_invoice = VendorInvoice.new
    vendor_invoice.time_entries_without_rates.should be_empty
  end

  it 'should be empty if all time entries have a cost (rate)' do
    time_entry_one = time_entry_mock_factory(1, { :cost => 100 })
    time_entry_two = time_entry_mock_factory(2, { :cost => 100 })
    
    vendor_invoice = VendorInvoice.new
    vendor_invoice.should_receive(:time_entries).and_return([time_entry_one, time_entry_two])
    vendor_invoice.time_entries_without_rates.should be_empty
  end

  it 'should return all the TimeEntries without a cost (rate)' do
    time_entry_one = time_entry_mock_factory(1, { :cost => 100 })
    time_entry_two = time_entry_mock_factory(2, { :cost => 0, :hours => 100.335 })
    time_entry_three = time_entry_mock_factory(3, { :cost => 0, :hours => 10.1 })
    
    vendor_invoice = VendorInvoice.new
    vendor_invoice.should_receive(:time_entries).and_return([time_entry_one, time_entry_two, time_entry_three])
    vendor_invoice.time_entries_without_rates.should eql([time_entry_two, time_entry_three])
  end
end


describe VendorInvoice, "#hours_without_rates" do
  include VendorInvoiceSpecHelper

  it 'should return 0.0 if there are no time entries' do
    vendor_invoice = VendorInvoice.new
    vendor_invoice.hours_without_rates.should eql(0)
  end

  it 'should return 0 if all time entries have a cost (rate)' do
    time_entry_one = time_entry_mock_factory(1, { :cost => 100 })
    time_entry_two = time_entry_mock_factory(2, { :cost => 100 })
    
    vendor_invoice = VendorInvoice.new
    vendor_invoice.should_receive(:time_entries).and_return([time_entry_one, time_entry_two])
    vendor_invoice.hours_without_rates.should eql(0)
  end
  it 'should return the sum of all the time entries without a cost (rate)' do
    time_entry_one = time_entry_mock_factory(1, { :cost => 100 })
    time_entry_two = time_entry_mock_factory(2, { :cost => 0, :hours => 100.335 })
    time_entry_three = time_entry_mock_factory(3, { :cost => 0, :hours => 10.1 })
    
    vendor_invoice = VendorInvoice.new
    vendor_invoice.should_receive(:time_entries).and_return([time_entry_one, time_entry_two, time_entry_three])
    vendor_invoice.hours_without_rates.should be_close(110.435, 0.001)
  end
end
