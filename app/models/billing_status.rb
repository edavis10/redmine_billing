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
  
  def self.find_by_id(id)
    return id.to_sym if Statuses.key?(id.to_sym)
  end

  def self.find_by_name(id)
    return Statuses[id.to_sym]
  end
end
