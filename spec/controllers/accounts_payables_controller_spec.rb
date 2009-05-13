require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AccountsPayablesControllerSpecHelper
  def login
    # Redmine Application controller
    controller.stub!(:user_setup)
    controller.stub!(:check_if_login_required).and_return(true)
    controller.stub!(:set_localization)

    controller.stub!(:authorize).and_return(true)
    @current_user = mock_model(User)
    @current_user.stub!(:admin?).and_return(false)
    User.stub!(:current).and_return(@current_user)
  end

  def user_factory(id, options = { })
    object_options = { 
      :id => id,
      :to_param => id.to_s
    }.merge(options)
    
    user = mock_model(User, object_options)
    return user
  end
  
  def vendor_invoice_factory(id, options = { })
    object_options = { 
      :id => id,
      :to_param => id.to_s
    }.merge(options)
    
    vendor_invoice = mock_model(VendorInvoice, object_options)
    return vendor_invoice
  end
end

describe AccountsPayablesController do

  #Delete this example and add some real ones
  it "should use AccountsPayablesController" do
    controller.should be_an_instance_of(AccountsPayablesController)
  end

end

describe AccountsPayablesController, "#index" do
  include AccountsPayablesControllerSpecHelper
  
  before(:each) do
    login
    
    @vendor_invoice_one = vendor_invoice_factory(1)
    @vendor_invoice_two = vendor_invoice_factory(2)
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]

    @user_one = user_factory(1)
    @user_one.stub!(:vendor_invoices).and_return(@vendor_invoices)

    @user_two = user_factory(2)
    @user_two.stub!(:vendor_invoices).and_return([])
    @users = [@user_one, @user_two]
    User.stub!(:find).with(:all).and_return(@users)
    
    controller.stub!(:allowed_projects).and_return([])
  end
  
  it 'should be successful' do
    get :index
    response.should be_success
  end

  it 'should load the vendor invoice filter'

  it 'should render the index template' do
    get :index
    response.should render_template('accounts_payables/index')
  end
end

describe AccountsPayablesController, "#filter" do
  include AccountsPayablesControllerSpecHelper
  
  before(:each) do
    login
    
    @vendor_invoice_one = vendor_invoice_factory(1)
    @vendor_invoice_two = vendor_invoice_factory(2)
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]

    @user_one = user_factory(1)
    @user_one.stub!(:vendor_invoices).and_return(@vendor_invoices)

    @user_two = user_factory(2)
    @user_two.stub!(:vendor_invoices).and_return([])
    @users = [@user_one, @user_two]
    User.stub!(:find).with(:all).and_return(@users)
    
    controller.stub!(:allowed_projects).and_return([])
  end
  
  it 'should be successful' do
    post :filter, :vendor_invoice_filter => {}
    response.should be_success
  end

  it 'should load the vendor invoice filter' do
    controller.should_receive(:load_vendor_invoice_filter)
    post :filter, :vendor_invoice_filter => {}
  end

  it 'should render the index template' do
    post :filter, :vendor_invoice_filter => {}
    response.should render_template('accounts_payables/index')
  end
end

describe AccountsPayablesController, "#show" do
  include AccountsPayablesControllerSpecHelper
  
  before(:each) do
    login
    @current_user.should_receive(:allowed_to?).with(:use_accounts_payable, nil, { :global => true }).and_return(true)
    
    @vendor_invoice = vendor_invoice_factory(1)
    VendorInvoice.stub!(:find).and_return(@vendor_invoice)
  end

  it 'should be successful' do
    get :show, :id => @vendor_invoice.id
    response.should be_success
  end

  it 'should load the vendor invoice' do
    get :show, :id => @vendor_invoice.id
    assigns[:vendor_invoice].should eql(@vendor_invoice)
  end

  it 'should render the show template' do
    get :show, :id => @vendor_invoice.id
    response.should render_template('accounts_payables/show')
  end
end

describe AccountsPayablesController, "#new" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice = vendor_invoice_factory(1)
    FixedVendorInvoice.stub!(:new).and_return(@vendor_invoice)
  end
  
  it 'should be successful' do
    get :new
    response.should be_success
  end

  it 'should load a new vendor invoice' do
    FixedVendorInvoice.should_receive(:new).and_return(@vendor_invoice)
    get :new
    assigns[:vendor_invoice].should_not be_nil
  end

  it 'should render the edit template' do
    get :new
    response.should render_template('accounts_payables/edit')
  end
end

describe AccountsPayablesController, "#new hourly" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice = vendor_invoice_factory(1,:type => 'HourlyVendorInvoice')
    HourlyVendorInvoice.stub!(:new).and_return(@vendor_invoice)
  end
  
  it 'should be successful' do
    get :new, :type => 'hourly'
    response.should be_success
  end

  it 'should load a new vendor invoice' do
    HourlyVendorInvoice.should_receive(:new).and_return(@vendor_invoice)
    get :new, :type => 'hourly'
    assigns[:vendor_invoice].should_not be_nil
  end

  it 'should render the edit template' do
    get :new, :type => 'hourly'
    response.should render_template('accounts_payables/edit')
  end

  it 'should assign any passed in time_entry_ids' do
    @vendor_invoice.should_receive(:time_entry_ids=).with(['12','13'])
    @vendor_invoice.stub!(:set_default_user)
    get :new, :type => 'hourly', :time_entry_ids => ['12','13']
  end

  it 'should pre-select the user based on the first Time Entry' do
    time_entry_one = mock_model(TimeEntry, :spent_on => Date.today, :user_id => 1)
    time_entry_two = mock_model(TimeEntry, :spent_on => Date.yesterday, :user_id => 2)
    time_entry_ids = [time_entry_one.id, time_entry_two.id]
    
    @vendor_invoice.should_receive(:time_entry_ids=).with(time_entry_ids)
    @vendor_invoice.should_receive(:set_default_user)
    get :new, :type => 'hourly', :time_entry_ids => time_entry_ids

  end
end

describe AccountsPayablesController, "#create with successful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    @params = { :vendor_invoice => { :number => 'Test001', :invoiced_on => Date.today, :comment => 'A comment', :amount => '200.30', :billing_status => 'unbilled' }}
    login
    @vendor_invoice = vendor_invoice_factory(1)
    @vendor_invoice.stub!(:save).and_return(true)
    FixedVendorInvoice.stub!(:new).and_return(@vendor_invoice)
  end
  
  it 'should redirect to the vendor invoice' do
    post :create, @params
    response.should redirect_to(accounts_payable_path(@vendor_invoice))
  end

  it 'should save the vendor invoice' do
    @vendor_invoice.should_receive(:save).and_return(true)
    post :create, @params
  end

  it 'should set the flash message' do
    post :create, @params 
    flash[:notice].should match(/successfully created/)
  end
end

describe AccountsPayablesController, "#create with unsuccessful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    @params = { :vendor_invoice => { :number => 'Test001', :invoiced_on => Date.today, :comment => 'A comment', :amount => '200.30', :billing_status => 'unbilled' }}
    login
    @vendor_invoice = vendor_invoice_factory(1)
    @vendor_invoice.stub!(:save).and_return(false)
    FixedVendorInvoice.stub!(:new).and_return(@vendor_invoice)
  end

  it 'should render the new vendor invoice form' do
    post :create, @params
    response.should render_template('accounts_payables/edit')
  end

  it 'should not save the vendor invoice' do
    @vendor_invoice.should_receive(:save).and_return(false)
    post :create, @params
  end
end

describe AccountsPayablesController, "#edit" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice = vendor_invoice_factory(1)
    VendorInvoice.stub!(:find).and_return(@vendor_invoice)
  end

  it 'should be successful' do
    get :edit, :id => @vendor_invoice.id
    response.should be_success
  end
  
  it 'should load the vendor invoice' do
    get :edit, :id => @vendor_invoice.id
    assigns[:vendor_invoice].should eql(@vendor_invoice)
  end

  it 'should render the edit template' do
    get :edit, :id => @vendor_invoice.id
    response.should render_template('accounts_payables/edit')
  end
end

describe AccountsPayablesController, "#update with successful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    @params = { :vendor_invoice => { :id => 1, :number => 'Test001', :invoiced_on => Date.today, :comment => 'A comment', :amount => '200.30', :billing_status => 'unbilled' }}
    login
    @vendor_invoice = vendor_invoice_factory(1)
    @vendor_invoice.stub!(:update_attributes).and_return(true)
    VendorInvoice.stub!(:find).and_return(@vendor_invoice)
  end

  it 'should redirect to the vendor invoice' do
    put :update, @params
    response.should redirect_to(accounts_payable_path(@vendor_invoice))
  end

  it 'should update the vendor invoice' do
    @vendor_invoice.should_receive(:update_attributes).and_return(true)
    put :update, @params
  end

  it 'should set the flash message' do
    put :update, @params 
    flash[:notice].should match(/successfully updated/)
  end
end

describe AccountsPayablesController, "#update with unsuccessful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    @params = { :vendor_invoice => { :id => 1, :number => 'Test001', :invoiced_on => Date.today, :comment => 'A comment', :amount => '200.30', :billing_status => 'unbilled' }}
    login
    @vendor_invoice = vendor_invoice_factory(1)
    @vendor_invoice.stub!(:update_attributes).and_return(false)
    VendorInvoice.stub!(:find).and_return(@vendor_invoice)
  end
  
  it 'should redirect to the edit vendor invoice form' do
    put :update, @params
    response.should render_template('accounts_payables/edit')
  end

  it 'should not update the vendor invoice' do
    @vendor_invoice.should_receive(:update_attributes).and_return(false)
    post :update, @params
  end
end

describe AccountsPayablesController, "#bulk_edit" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice_one = vendor_invoice_factory(1)
    @vendor_invoice_two = vendor_invoice_factory(2)
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]
    VendorInvoice.stub!(:find_all_by_id).with(['1','2']).and_return(@vendor_invoices)
  end

  it 'should be successful' do
    post :bulk_edit, :ids => ['1','2']
    response.should be_success
  end
  
  it 'should load the vendor invoices' do
    post :bulk_edit, :ids => ['1','2']
    assigns[:vendor_invoices].should eql(@vendor_invoices)
  end

  it 'should render the bulk_edit template' do
    post :bulk_edit, :ids => ['1','2']
    response.should render_template('accounts_payables/bulk_edit')
  end
end

describe AccountsPayablesController, "#bulk_update with successful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice_one = vendor_invoice_factory(1)
    @vendor_invoice_one.stub!(:update_attributes).and_return(true)
    @vendor_invoice_two = vendor_invoice_factory(2)
    @vendor_invoice_two.stub!(:update_attributes).and_return(true)
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]
    @params = { :invoiced_on => Date.today, :ids => [@vendor_invoice_one.id, @vendor_invoice_two.id], :comment => 'comment'}
    VendorInvoice.stub!(:find_all_by_id).and_return(@vendor_invoices)
  end

  it 'should redirect to the vendor invoice list' do
    put :bulk_update, @params
    response.should redirect_to(accounts_payables_path)
  end

  it 'should update the vendor invoices' do
    VendorInvoice.should_receive(:find_all_by_id).and_return(@vendor_invoices)
    @vendor_invoice_one.should_receive(:update_attributes).and_return(true)
    @vendor_invoice_two.should_receive(:update_attributes).and_return(true)
    put :bulk_update, @params
  end

  it 'should set the flash message' do
    put :bulk_update, @params 
    flash[:notice].should match(/successfully updated/)
  end
end

describe AccountsPayablesController, "#bulk_update with an unsuccessful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    login
    @vendor_invoice_one = vendor_invoice_factory(1)
    @vendor_invoice_one.stub!(:update_attributes).and_return(false)
    @vendor_invoice_two = vendor_invoice_factory(2)
    @vendor_invoice_two.stub!(:update_attributes).and_return(true)
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]
    @params = { :invoiced_on => Date.today, :ids => [@vendor_invoice_one.id, @vendor_invoice_two.id], :comment => 'comment'}
    VendorInvoice.stub!(:find_all_by_id).and_return(@vendor_invoices)
  end

  it 'should redirect to the vendor invoice list' do
    put :bulk_update, @params
    response.should redirect_to(accounts_payables_path)
  end

  it 'should update the vendor invoices' do
    VendorInvoice.should_receive(:find_all_by_id).and_return(@vendor_invoices)
    @vendor_invoice_one.should_receive(:update_attributes).and_return(false)
    @vendor_invoice_two.should_receive(:update_attributes).and_return(true)
    put :bulk_update, @params
  end

  it 'should save the unsaved vendor invoice ids to @unsaved_ids' do
    put :bulk_update, @params
    assigns[:unsaved_ids].should_not be_empty
    assigns[:unsaved_ids].should eql([@vendor_invoice_one.id])
  end
  
  it 'should set the flash message' do
    put :bulk_update, @params 
    flash[:error].should match(/failed/i)
    flash[:error].should match(/##{@vendor_invoice_one.id}/i)
  end
end

describe AccountsPayablesController, "#timesheet" do
  include AccountsPayablesControllerSpecHelper
  integrate_views
  
  before(:each) do
    login
    
  end
  
  it 'should be successful' do
    get :timesheet, :time_entry_ids => [ ]
    response.should be_success
  end

  it 'should render the timesheet template' do
    get :timesheet, :time_entry_ids => [ ]
    response.should render_template('accounts_payables/timesheet')
  end
  
  it 'should load the vendor_invoices' do
    @vendor_invoice_one = vendor_invoice_factory(1, :number => '100012')
    @vendor_invoice_two = vendor_invoice_factory(2, :number => 'A004')
    @vendor_invoices = [@vendor_invoice_one, @vendor_invoice_two]
    HourlyVendorInvoice.should_receive(:find).with(:all).and_return(@vendor_invoices)

    get :timesheet, :time_entry_ids => []
    assigns[:vendor_invoices].should eql(@vendor_invoices)
  end
end
