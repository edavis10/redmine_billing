require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module AccountsPayablesControllerSpecHelper
  def login
    # Redmine Application controller
    controller.stub!(:user_setup)
    controller.stub!(:check_if_login_required).and_return(true)
    controller.stub!(:set_localization)

    controller.stub!(:authorize).and_return(true)
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
  end
  
  it 'should be successful' do
    get :index
    response.should be_success
  end

  it 'should load all users and their vendor invoices' do
    get :index
    assigns[:users].should eql(@users)
  end

  it 'should render the index template' do
    get :index
    response.should render_template('accounts_payables/index')
  end
end

describe AccountsPayablesController, "#show" do
  include AccountsPayablesControllerSpecHelper
  
  before(:each) do
    login
    
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
    VendorInvoice.stub!(:new).and_return(@vendor_invoice)
  end
  
  it 'should be successful' do
    get :new
    response.should be_success
  end

  it 'should load a new vendor invoice' do
    VendorInvoice.should_receive(:new).and_return(@vendor_invoice)
    get :new
    assigns[:vendor_invoice].should_not be_nil
  end

  it 'should render the edit template' do
    get :new
    response.should render_template('accounts_payables/edit')
  end
end

describe AccountsPayablesController, "#create with successful save" do
  include AccountsPayablesControllerSpecHelper

  before(:each) do
    @params = { :vendor_invoice => { :number => 'Test001', :invoiced_on => Date.today, :comment => 'A comment', :amount => '200.30', :billing_status => 'unbilled' }}
    login
    @vendor_invoice = vendor_invoice_factory(1)
    @vendor_invoice.stub!(:save).and_return(true)
    VendorInvoice.stub!(:new).and_return(@vendor_invoice)
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
    VendorInvoice.stub!(:new).and_return(@vendor_invoice)
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

