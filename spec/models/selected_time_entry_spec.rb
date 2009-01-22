require File.dirname(__FILE__) + '/../spec_helper'

module SelectedTimeEntrySpecHelper
  def time_entry_factory(id, options = { })
    object_options = { 
      :user => nil,
      :user_id => nil,
      :hours => 0,
      :project_id => nil
    }.merge(options)
    
    time_entry = mock_model(TimeEntry, object_options)
    return time_entry
  end
  
end

describe SelectedTimeEntry, 'to_json' do
  it 'should return a string' do
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.to_json.should be_a_kind_of(String)
  end
  
  it 'should be a valid JSON string' do
    @selected_time_entry = SelectedTimeEntry.new
    lambda { 
      JSON.parse(@selected_time_entry.to_json)
    }.should_not raise_error(JSON::ParserError)
    
  end

  it 'should collect member data' do
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.should_receive(:collect_member_data).and_return([])
    @selected_time_entry.to_json
  end
end

describe SelectedTimeEntry, 'collect_member_data' do
  include SelectedTimeEntrySpecHelper

  it 'should return an Array of Hashes' do
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.collect_member_data.should be_a_kind_of(Array)
  end
  
  it 'should contain a record per User' do
    @user_one = mock_model(User, :id => 1)
    @user_one.stub!(:name).and_return("Test User")
    User.stub!(:find).with(1).and_return(@user_one)
    @time_entry_one = time_entry_factory(1, :user => @user_one, :user_id => @user_one.id)
    
    @user_two = mock_model(User, :id => 2)
    @user_two.stub!(:name).and_return("Test User Two")
    User.stub!(:find).with(2).and_return(@user_two)
    @time_entry_two = time_entry_factory(2, :user => @user_two, :user_id => @user_two.id)

    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.time_entries = [@time_entry_one, @time_entry_two]
    @selected_time_entry.stub!(:total_amount_for_user)
    @selected_time_entry.collect_member_data.should have(2).things
    
  end
  
  describe 'response record' do
    before(:each) do
      @user = mock_model(User, :id => 1)
      @user.stub!(:name).and_return("Test User")
      User.stub!(:find).with(1).and_return(@user)
      @time_entry_one = time_entry_factory(1, :user => @user, :user_id => @user.id)

      @selected_time_entry = SelectedTimeEntry.new
      @selected_time_entry.time_entries = [@time_entry_one]
      @selected_time_entry.stub!(:total_amount_for_user)
    end
    
    it 'should have the user name' do
      @user.should_receive(:name).and_return("Test User")

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:name].should eql('Test User')
    end

    it 'should have the count of time_entries for the user' do
      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:number_of_entries].should eql(1)
    end

    it 'should have the total time for the user' do
      @selected_time_entry.should_receive(:total_of_user_time_entries).and_return(4.0)

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:time].should eql(4.0)
    end

    it 'should have an amount for the user' do
      @selected_time_entry.should_receive(:total_amount_for_user).and_return(1_000.00)

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:amount].should eql(1_000.00)
    end

    it 'should format the amount into currency' do
      @selected_time_entry.stub!(:total_amount_for_user).and_return(1_000.00)

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:formatted_amount].should eql("$1,000.00")
    end

    it 'should format time into a hundredths' do
      @selected_time_entry.stub!(:total_of_user_time_entries).and_return(4.125)

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:formatted_time].should eql("4.13")
    end

  end
end

describe SelectedTimeEntry, 'total_of_user_time_entries (private)' do
  it 'should total the hours of the time_entries' do
    time_entry_one = mock_model(TimeEntry, :id => 1, :hours => 2.0)
    time_entry_two = mock_model(TimeEntry, :id => 2, :hours => 1.0)
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.send(:total_of_user_time_entries, [time_entry_one, time_entry_two]).should eql(3.0)
  end

  it 'should skip over nil hours' do
    time_entry_one = mock_model(TimeEntry, :id => 1, :hours => 2.0)
    time_entry_two = mock_model(TimeEntry, :id => 2, :hours => 1.0)
    time_entry_three = mock_model(TimeEntry, :id => 2, :hours => nil)
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.send(:total_of_user_time_entries, [time_entry_one, time_entry_two, time_entry_three]).should eql(3.0)
  end
end

describe SelectedTimeEntry, 'total_amount_for_user (private)' do
  it 'should total the cost of each time_entry' do
    time_entry_one = mock_model(TimeEntry, :id => 1, :cost => 400.0)
    time_entry_two = mock_model(TimeEntry, :id => 2, :cost => 200.0)
    time_entry_three = mock_model(TimeEntry, :id => 2, :cost => 0.0)

    selected_time_entry = SelectedTimeEntry.new
    selected_time_entry.send(:total_amount_for_user, [time_entry_one, time_entry_two, time_entry_three]).should eql(600.0)
  end
end
