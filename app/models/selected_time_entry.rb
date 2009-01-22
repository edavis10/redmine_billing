require 'json'

class SelectedTimeEntry
  include ActionView::Helpers::NumberHelper
  
  attr_accessor :time_entries
  attr_accessor :grouped_time_entries
  
  def self.find_all_by_id(ids)
    object = SelectedTimeEntry.new
    object.time_entries = TimeEntry.find_all_by_id(ids)
    return object
  end
  
  def to_json
    members = collect_member_data
    total_time = number_with_precision(members.collect {|member| member[:time]}.sum, 2)
    total_amount = number_to_currency(members.collect {|member| member[:amount]}.sum, :precision => 2)
    total_entries = members.collect {|member| member[:number_of_entries]}.sum

    data = { 
      :total_time => total_time,
      :total_amount => total_amount,
      :total_entries => total_entries,
      :members => members
    }
    return data.to_json
  end
  
  def collect_member_data
    data = []
    return data if self.time_entries.nil? || self.time_entries.empty?

    group_time_entries_by_user
    
    self.grouped_time_entries.each do |user_id, time_entries|
      user = User.find(user_id)
      account = { }
      account[:name] = user.name
      account[:number_of_entries] = time_entries.length
      account[:time] = total_of_user_time_entries(time_entries)
      account[:amount] = total_amount_for_user(time_entries)
      account[:formatted_amount] = number_to_currency(account[:amount], :precision => 2)
      account[:formatted_time] = number_with_precision(account[:time], 2)
      data << account
    end

    return data
  end
  
  private
  
  def total_of_user_time_entries(time_entries)
    time_entries.collect(&:hours).reject { |t| t.nil? }.sum
  end
  
  def total_amount_for_user(time_entries)
    return time_entries.collect(&:cost).compact.sum
  end

  # Groups time entries into a hash based on the user_id
  def group_time_entries_by_user
    self.grouped_time_entries = { }
    self.time_entries.each do |time_entry|
      unless self.grouped_time_entries.key?(time_entry.user_id)
        self.grouped_time_entries[time_entry.user_id] = []
      end
      
      self.grouped_time_entries[time_entry.user_id] << time_entry
    end
  end
end
