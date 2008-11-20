require 'json'

class SelectedTimeEntry
  attr_accessor :time_entries
  
  def self.find_all_by_id(ids)
    object = SelectedTimeEntry.new
    object.time_entries = TimeEntry.find_all_by_id(ids)
    return object
  end
  
  def to_json
    total_time = 0.0.to_s
    total_amount = 0.0.to_s
    total_entries = 0.to_s
    # members - name, time, amount
    data = { 
      :total_time => total_time,
      :total_amount => total_amount,
      :total_entries => total_entries,
      :members => [
                   {
                     :name => "Eric Davis",
                     :number_of_entries => 4,
                     :time => 5.3,
                     :amount => 1000000.01
                   },
                   {
                     :name => "Joe Don",
                     :number_of_entries => 6,
                     :time => 2.3,
                     :amount => 123.01
                   }
                  ]
    }
    return data.to_json
  end
end
