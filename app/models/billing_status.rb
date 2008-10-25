class BillingStatus
  Statuses = { 
    :unbilled => "Unbilled",
    :billed => "Billed",
    :approved => "Approved",
    :paid => "Paid",
    :hold => "On Hold",
    :rejected => "Rejected",
    :pro_bono => "Pro-bono",
    :internal => "Internal"
  }
  
  def self.to_array
    Statuses.invert.sort.to_a
  end
  
  def self.to_array_of_strings
    Statuses.invert.sort.map {|value,key| [value, key.to_s] }
  end
  
  def self.find_by_id(id)
    return id.to_sym if !id.nil? && Statuses.key?(id.to_sym)
  end

  def self.find_by_name(id)
    return Statuses[id.to_sym]
  end
  
  def self.names
    Statuses.keys
  end
  
  def self.values
    Statuses.values
  end
end
