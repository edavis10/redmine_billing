require File.dirname(__FILE__) + '/../spec_helper'

describe SelectedTimeEntry, 'to_json' do
  it 'should return a json string'
  it 'should collect member data'
end

describe SelectedTimeEntry, 'collect_member_data' do
  it 'should return an Array of Hashes' do
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.collect_member_data.should be_a_kind_of(Array)
  end
  
  it 'should contain a record per User' do
    @user_one = mock_model(User)
    @user_one.stub!(:name).and_return("Test User")
    @time_entry_one = mock_model(TimeEntry, :id => 1)
    @time_entry_one.stub!(:user).and_return(@user_one)
    
    @user_two = mock_model(User)
    @user_two.stub!(:name).and_return("Test User Two")
    @time_entry_two = mock_model(TimeEntry, :id => 2)
    @time_entry_two.stub!(:user).and_return(@user_two)

    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.time_entries = [@time_entry_one, @time_entry_two]
    @selected_time_entry.collect_member_data.should have(2).things
    
  end
  
  describe 'response record' do
    before(:each) do
      @user = mock_model(User)
      @user.stub!(:name).and_return("Test User")
      @time_entry_one = mock_model(TimeEntry, :id => 1)
      @time_entry_one.should_receive(:user).and_return(@user)

      @selected_time_entry = SelectedTimeEntry.new
      @selected_time_entry.time_entries = [@time_entry_one]
    end
    
    it 'should have the user name' do
      @user.should_receive(:name).and_return("Test User")

      response = @selected_time_entry.collect_member_data
      response.should have_at_least(1).thing
      response[0][:name].should eql('Test User')
    end

    it 'should have the count of time_entries for the user'

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
  
  it 'should select all the Users from the Time Entries' do
    @user = mock_model(User)
    @user.stub!(:name).and_return("Test User")
    @time_entry_one = mock_model(TimeEntry, :id => 1)
    @time_entry_one.should_receive(:user).and_return(@user)
    @time_entry_two = mock_model(TimeEntry, :id => 2)
    @time_entry_two.should_receive(:user).and_return(@user)
    
    @selected_time_entry = SelectedTimeEntry.new
    @selected_time_entry.time_entries = [@time_entry_one, @time_entry_two]
    
    @selected_time_entry.collect_member_data
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
