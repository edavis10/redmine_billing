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
end
