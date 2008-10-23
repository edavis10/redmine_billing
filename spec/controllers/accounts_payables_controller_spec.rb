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
  it 'should be successful'

  it 'should load the vendor invoice'

  it 'should render the show template'
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
  it 'should redirect to the vendor invoice'

  it 'should save the vendor invoice'

  it 'should set the flash message'
end

describe AccountsPayablesController, "#create with unsuccessful save" do
  it 'should redirect to the new vendor invoice form'

  it 'should not save the vendor invoice'
end

describe AccountsPayablesController, "#edit" do
  it 'should be successful'

  it 'should load the vendor invoice'

  it 'should render the edit template'
end

describe AccountsPayablesController, "#update with successful save" do
  it 'should redirect to the vendor invoice'

  it 'should update the vendor invoice'

  it 'should set the flash message'
end

describe AccountsPayablesController, "#update with unsuccessful save" do
  it 'should redirect to the edit vendor invoice form'

  it 'should not update the vendor invoice'
end

describe AccountsPayablesController, "#destroy" do
  it 'should redirect to the vendor invoices list'

  it 'should delete the vendor invoice'

  it 'should set the flash message'
end

