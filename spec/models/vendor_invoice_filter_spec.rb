require File.dirname(__FILE__) + '/../spec_helper'

module VendorInvoiceFilterSpecHelper
  def vendor_invoice_filter_factory(options={ })
    object_options = { 
      :date_from => Date.today,
      :date_to => Date.today
    }.merge(options)
    
    
    return VendorInvoiceFilter.new(object_options)
  end
  
  def user_factory(id, options = { })
    object_options = { 
      :id => id,
      :to_param => id.to_s
    }.merge(options)

    user = mock_model(User, object_options)
    vendor_invoice_one = mock_model(VendorInvoice, :id => '100' + id.to_s, :user => user, :invoiced_on => Date.today, :billing_status => 'paid')
    vendor_invoice_two = mock_model(VendorInvoice, :id => '200' + id.to_s, :user => user, :invoiced_on => Date.today, :billing_status => 'paid')
    vendor_invoice_three = mock_model(VendorInvoice, :id => '300' + id.to_s, :user => user, :invoiced_on => Date.today, :billing_status => 'paid')
    vendor_invoice_mock = mock('vendor_invoice_mock')
    vendor_invoice_mock.stub!(:find).and_return([vendor_invoice_one, vendor_invoice_two, vendor_invoice_three])
    user.stub!(:vendor_invoices).and_return(vendor_invoice_mock)
    return user
  end

  def stub_non_member_user(projects)
    @current_user = mock_model(User)
    @current_user.stub!(:admin?).and_return(false)
    User.stub!(:current).and_return(@current_user)
  end
  
  def stub_normal_user(projects)
    @current_user = mock_model(User)
    @current_user.stub!(:admin?).and_return(false)
    User.stub!(:current).and_return(@current_user)
  end
  
  def stub_manager_user(projects)
    @current_user = mock_model(User)
    @current_user.stub!(:admin?).and_return(false)
    User.stub!(:current).and_return(@current_user)
  end
  
  def stub_admin_user
    @current_user = mock_model(User)
    @current_user.stub!(:admin?).and_return(true)
    User.stub!(:current).and_return(@current_user)    
  end
end

describe VendorInvoiceFilter do
  it 'should not be an ActiveRecord class' do
    VendorInvoiceFilter.should_not be_a_kind_of(ActiveRecord::Base)
  end
end

describe VendorInvoiceFilter, 'initializing' do
  it 'should initialize vendor_invoices to an empty Hash' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.vendor_invoices.should be_a_kind_of(Hash)
    vendor_invoice_filter.vendor_invoices.should be_empty
  end

  it 'should initialize projects to an empty Array' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.projects.should be_a_kind_of(Array)
    vendor_invoice_filter.projects.should be_empty
  end

  it 'should initialize allowed_projects to an empty Array' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.allowed_projects.should be_a_kind_of(Array)
    vendor_invoice_filter.allowed_projects.should be_empty
  end

  it 'should initialize activities to an Array' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.activities.should be_a_kind_of(Array)
  end

  it 'should initialize users to an Array' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.users.should be_a_kind_of(Array)
  end

  it 'should initialize billing status to an Array' do 
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.billing_status.should be_a_kind_of(Array)
  end

  it 'should initialize vendor_invoices to the passed in options' do 
    data = { :test => true }
    vendor_invoice_filter = VendorInvoiceFilter.new({ :vendor_invoices => data })
    vendor_invoice_filter.vendor_invoices.should_not be_empty
    vendor_invoice_filter.vendor_invoices.should eql(data)
  end

  it 'should initialize allowed_projects to the passed in options' do 
    data = ['project1', 'project2']
    vendor_invoice_filter = VendorInvoiceFilter.new({ :allowed_projects => data })
    vendor_invoice_filter.allowed_projects.should_not be_empty
    vendor_invoice_filter.allowed_projects.should eql(data)
  end

  it 'should initialize activities to the integers of the passed in options' do 
    act1 = mock('act1')
    act1.stub!(:to_i).and_return(200)
    act2 = mock('act2')
    act2.stub!(:to_i).and_return(300)
    data = [act1, act2]
    vendor_invoice_filter = VendorInvoiceFilter.new({ :activities => data })
    vendor_invoice_filter.activities.should_not be_empty
    vendor_invoice_filter.activities.should eql([200, 300])
  end

  it 'should initialize users to the users passed in options' do 
    user1 = mock_model(User, :id => 100)
    user2 = mock_model(User, :id => 101)
    data = [user1.id, user2.id]
    User.should_receive(:find).with(100).and_return(user1)
    User.should_receive(:find).with(101).and_return(user2)
    
    vendor_invoice_filter = VendorInvoiceFilter.new({ :users => data })
    vendor_invoice_filter.users.should_not be_empty
    vendor_invoice_filter.users.should eql([user1, user2])
  end

  it 'should initialize billing status to the passed in options' do 
    data = ['unbilled', 'paid']
    vendor_invoice_filter = VendorInvoiceFilter.new({ :billing_status => data})
    vendor_invoice_filter.billing_status.should eql(data)
  end

end

describe VendorInvoiceFilter, '#period=' do
  describe 'should set the date_to and date_from for' do
    before(:each) do
      @date = Date.new(2009,2,4)
      Date.stub!(:today).and_return(@date)
      @vendor_invoice_filter = VendorInvoiceFilter.new
    end
    
    it 'today' do
      @vendor_invoice_filter.should_receive(:date_from=).with(@date)
      @vendor_invoice_filter.should_receive(:date_to=).with(@date)
      @vendor_invoice_filter.period = 'today'
    end
    
    it 'yesterday' do
      @vendor_invoice_filter.should_receive(:date_from=).with(@date.yesterday)
      @vendor_invoice_filter.should_receive(:date_to=).with(@date.yesterday)
      @vendor_invoice_filter.period = 'yesterday'
    end
    
    it 'current_week' do
      @vendor_invoice_filter.should_receive(:date_from=).with(Date.new(2009, 2, 2))
      @vendor_invoice_filter.should_receive(:date_from).and_return(Date.new(2009, 2, 2))
      @vendor_invoice_filter.should_receive(:date_to=).with(Date.new(2009, 2, 8))
      @vendor_invoice_filter.period = 'current_week'
    end
    
    it 'last_week' do
      @vendor_invoice_filter.should_receive(:date_from=).with(Date.new(2009, 1, 26))
      @vendor_invoice_filter.should_receive(:date_from).and_return(Date.new(2009, 1, 26))
      @vendor_invoice_filter.should_receive(:date_to=).with(Date.new(2009, 2, 1))
      @vendor_invoice_filter.period = 'last_week'
    end
    
    it '7_days' do
      @vendor_invoice_filter.should_receive(:date_from=).with(@date - 7)
      @vendor_invoice_filter.should_receive(:date_to=).with(@date)
      @vendor_invoice_filter.period = '7_days'
    end
    
    it 'current_month' do
      @vendor_invoice_filter.should_receive(:date_from=).with(Date.new(2009, 2, 1))
      @vendor_invoice_filter.should_receive(:date_from).and_return(Date.new(2009, 2, 1))
      @vendor_invoice_filter.should_receive(:date_to=).with(Date.new(2009, 2, 28))
      @vendor_invoice_filter.period = 'current_month'
    end
    
    it 'last_month' do
      @vendor_invoice_filter.should_receive(:date_from=).with(Date.new(2009, 1, 1))
      @vendor_invoice_filter.should_receive(:date_from).and_return(Date.new(2009, 1, 1))
      @vendor_invoice_filter.should_receive(:date_to=).with(Date.new(2009, 1, 31))
      @vendor_invoice_filter.period = 'last_month'
    end
    
    it '30_days' do
      @vendor_invoice_filter.should_receive(:date_from=).with(@date - 30)
      @vendor_invoice_filter.should_receive(:date_to=).with(@date)
      @vendor_invoice_filter.period = '30_days'
    end
    
    it 'current_year' do
      @vendor_invoice_filter.should_receive(:date_from=).with(Date.new(2009,1,1))
      @vendor_invoice_filter.should_receive(:date_to=).with(Date.new(2009,12,31))
      @vendor_invoice_filter.period = 'current_year'
    end
    
    it 'all' do
      @vendor_invoice_filter.should_receive(:date_from=).with(nil)
      @vendor_invoice_filter.should_receive(:date_to=).with(nil)
      @vendor_invoice_filter.period = 'all'
    end
  end
end

describe VendorInvoiceFilter, '.filter!' do
  include VendorInvoiceFilterSpecHelper
  
  it 'should clear vendor_invoices' do
    vendor_invoice_filter = VendorInvoiceFilter.new
    vendor_invoice_filter.vendor_invoices = { :filled => 'data' }
    proc { 
      vendor_invoice_filter.filter!
    }.should change(vendor_invoice_filter, :vendor_invoices)
    
  end

  it 'should add a vendor_invoice array for each user' do
    vendor_invoice_filter = vendor_invoice_filter_factory

    user1 = user_factory(1)
    user2 = user_factory(2)

    stub_admin_user
    vendor_invoice_filter.users = [user1, user2]
    
    vendor_invoice_filter.filter!
    vendor_invoice_filter.vendor_invoices.should_not be_empty
    vendor_invoice_filter.vendor_invoices.should have(2).things
  end
  
  it 'should use the user as the key for each vendor_invoice' do
    vendor_invoice_filter = vendor_invoice_filter_factory

    user1 = user_factory(1)
    user2 = user_factory(2)

    stub_admin_user
    vendor_invoice_filter.users = [user1, user2]
    
    vendor_invoice_filter.filter!
    vendor_invoice_filter.vendor_invoices.keys.should include(user1)
    vendor_invoice_filter.vendor_invoices.keys.should include(user2)
  end
end

describe VendorInvoiceFilter, '.conditions_for_user' do
  include VendorInvoiceFilterSpecHelper

  it 'should return an ActiveRecord conditon' do
    vendor_invoice_filter = vendor_invoice_filter_factory
    user = user_factory(1)

    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions.should be_a_kind_of(Array)
    conditions[0].should be_a_kind_of(String)
    conditions[1].should be_a_kind_of(Hash)
  end
  
  it 'should include :from' do
    vendor_invoice_filter = vendor_invoice_filter_factory({ :date_from => 5.days.ago.to_date})
    user = user_factory(1)
    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions[1].values_at(:from).should eql([5.days.ago.to_date])
  end

  it 'should include :to' do
    vendor_invoice_filter = vendor_invoice_filter_factory({ :date_to => 15.days.ago.to_date})
    user = user_factory(1)
    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions[1].values_at(:to).should eql([15.days.ago.to_date])
  end

  it 'should include :biling_status' do
    vendor_invoice_filter = vendor_invoice_filter_factory({ :billing_status => ['paid', 'due']})
    user = user_factory(1)
    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions[1].values_at(:billing_status).should eql([['paid','due']])
  end
  
  it 'should include :projects' do
    vendor_invoice_filter = vendor_invoice_filter_factory
    vendor_invoice_filter.projects = [1,2]
    user = user_factory(1)
    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions[1].values_at(:projects).should eql([[1,2]])
  end
  
  it 'should include :activities' do
    vendor_invoice_filter = vendor_invoice_filter_factory({ :activities => [1,2]})
    user = user_factory(1)
    conditions = vendor_invoice_filter.conditions_for_user(user)
    
    conditions[1].values_at(:activities).should eql([[1,2]])
  end
end
