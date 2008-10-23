class BillingType
  Types = { 
    :fixed => "Fixed",
    :hourly => "Hourly"
  }
  
  def self.to_array
    Types.invert.to_a
  end
end
