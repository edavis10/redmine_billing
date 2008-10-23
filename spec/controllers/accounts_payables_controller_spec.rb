require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsPayablesController do

  #Delete this example and add some real ones
  it "should use AccountsPayablesController" do
    controller.should be_an_instance_of(AccountsPayablesController)
  end

end

describe AccountsPayablesController, "#index" do
  it 'should be successful'

  it 'should load all vendor invoices'

  it 'should render the index template'
end

describe AccountsPayablesController, "#show" do
  it 'should be successful'

  it 'should load the vendor invoice'

  it 'should render the show template'
end

describe AccountsPayablesController, "#new" do
  it 'should be successful'

  it 'should load a new vendor invoice'

  it 'should render the new template'
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

