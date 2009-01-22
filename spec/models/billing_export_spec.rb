require File.dirname(__FILE__) + '/../spec_helper'

describe BillingExport, "unbilled_labor" do
  before(:each) do
    @user_one = mock_model(User, :name => "Test User", :projects => [])
    @user_two = mock_model(User, :name => "Admin User", :projects => [])
    @users = [@user_one, @user_two]
    User.stub!(:find).with(:all).and_return(@users)
  end
  
  it 'should check all users' do
    User.should_receive(:find).with(:all).and_return(@users)
    BillingExport.unbilled_labor
  end

  it 'should return a set of nested Arrays with users and their values' do
    BillingExport.unbilled_labor.should be_a_kind_of(Array)
    BillingExport.unbilled_labor[0].should be_a_kind_of(Array)
  end

  it 'should sort the response' do
    BillingExport.unbilled_labor[0][0].should eql(@user_two.name)
    BillingExport.unbilled_labor[1][0].should eql(@user_one.name)
  end

  it "should total up the cost of labor that hasn't been billed" do
    project = mock_model(Project)
    project.stub!(:time_entries).and_return(TimeEntry)
    
    @user_one.should_receive(:projects).and_return([project])
    @user_two.should_receive(:projects).and_return([project])

    time_entry_one = mock_model(TimeEntry, :hours => 10, :cost => 250.0)
    time_entry_two = mock_model(TimeEntry, :hours => 100, :cost => 10000.0)
    TimeEntry.should_receive(:find_all_by_user_id_and_vendor_invoice_id).with(@user_one.id, nil).and_return([time_entry_one])
    TimeEntry.should_receive(:find_all_by_user_id_and_vendor_invoice_id).with(@user_two.id, nil).and_return([time_entry_two])

    result = BillingExport.unbilled_labor
    result[0][0].should eql(@user_two.name)
    result[0][1].should eql(10000.0)

    result[1][0].should eql(@user_one.name)
    result[1][1].should eql(250.0)
  end
end
