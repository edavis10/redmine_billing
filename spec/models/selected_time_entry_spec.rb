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
  it 'should return a json string'
  it 'should collect member data'
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

    it 'should have an amount for the user'
    it 'should format the amount into currency'
    it 'should format time into a hundredths'
  end
  
  it 'should total the time from the Time Entries'
  
  it 'should calculate the amount from the Time Entries and the Members rate'
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
