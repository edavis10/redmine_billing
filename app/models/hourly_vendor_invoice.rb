class HourlyVendorInvoice < VendorInvoice

  # Set the default user to the owner of the first time entry
  def set_default_user
    if self.user_ids.empty? && !self.time_entries.empty?
      first_entry = self.time_entries.sort {|a,b| a.spent_on <=> b.spent_on }.first
      self.user_ids = [first_entry.user_id] unless first_entry.nil?
    end
  end
end
