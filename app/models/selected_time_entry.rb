require 'json'

class SelectedTimeEntry
  include ActionView::Helpers::NumberHelper
  
  attr_accessor :time_entries
  
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
    entry_ids = self.time_entries.collect(&:id).uniq
    users = self.time_entries.collect(&:user).uniq
    users.each do |user|
      account = { }
      user_time_entries = TimeEntry.find_all_by_id_and_user_id(entry_ids, user.id)

      account[:name] = user.name
      account[:number_of_entries] = user_time_entries.length
      account[:time] = user_time_entries.collect(&:hours).reject { |t| t.nil? }.sum
      account[:amount] = 0.0
      user_time_entries.each do |te|
        # Wish there was a standard API to get member rates
        mem = Member.find_by_user_id_and_project_id(te.user_id, te.project_id)
        if !mem.nil? && mem.respond_to?(:rate) && !mem.rate.nil?
          account[:amount] += mem.rate * te.hours
        end
      end
      account[:formatted_amount] = number_to_currency(account[:amount], :precision => 2)
      account[:formatted_time] = number_with_precision(account[:time], 2)
      data << account
    end
    
    return data
  end
end
