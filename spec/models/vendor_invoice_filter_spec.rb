require File.dirname(__FILE__) + '/../spec_helper'

module VendorInvoiceFilterSpecHelper
  def vendor_invoice_factory(options={ })
    object_options = { 
      :id => id,
      :date_from => Date.today,
      :date_to => Date.today
    }.merge(options)
    
    
    return VendorInvoiceFilter.new(object_options)
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

  it 'should initialize users to the ids of the passed in options' do 
    user1 = mock('user1')
    user1.stub!(:to_i).and_return(100)
    user2 = mock('user2')
    user2.stub!(:to_i).and_return(101)
    data = [user1, user2]
    vendor_invoice_filter = VendorInvoiceFilter.new({ :users => data })
    vendor_invoice_filter.users.should_not be_empty
    vendor_invoice_filter.users.should eql([100, 101])
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

end
