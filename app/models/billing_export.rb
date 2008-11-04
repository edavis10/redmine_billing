class BillingExport
  def self.unbilled_po
    # all unarchived
    projects = Project.find_all_by_status(Project::STATUS_ACTIVE)
    
    totals = { }
    projects.each do |project|
      amount_billed = 0
      # Fixed amount invoices
      ve = VendorInvoice.find(:all, :conditions => {:project_id => project.id, :billing_type => "fixed"})
      amount_billed += ve.collect(&:amount).reject { |amount| amount.nil?}.sum

      # Hourly
      ve = VendorInvoice.find(:all,
                              :conditions => ["#{TimeEntry.table_name}.project_id = ? AND billing_type = ?",
                                              project.id,
                                              'hourly'],
                              :include => :time_entries)
      amount_billed += ve.collect {|i| i.amount_for_user }.reject { |amount| amount.nil? }.sum
      
      total_value = project.total_value || 0
      
      totals[project.name] = total_value - amount_billed
    end

    return totals.sort
  end

  

  def self.unspent_labor
    # all unarchived
    projects = Project.find_all_by_status(Project::STATUS_ACTIVE)

    totals = { }

    # Guard in case the budget_plugin isn't installed
    if Object.const_defined?("Budget")
      projects.each do |project|
        budget = Budget.new(project.id)
        totals[project.name] = budget.labor_budget_left || 0.0
      end
    else
      totals["Please install the budget_plugin to use this feature"] = 0
    end

    return totals.sort
  end
end
