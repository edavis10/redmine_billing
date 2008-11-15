class BillingExport
  include ActionView::Helpers::NumberHelper
  extend ActionView::Helpers::NumberHelper

  Precision = 2

  
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
      
      totals[project.name] = number_with_precision(total_value - amount_billed, Precision)
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
        totals[project.name] = number_with_precision(budget.labor_budget_left || 0.0, Precision)
      end
    else
      totals["Please install the budget_plugin to use this feature"] = 0
    end

    return totals.sort
  end
  
  def self.unbilled_labor
    totals = { }

    # All users
    users = User.find(:all)
    users.each do |user|
      totals[user.name] = 0.0

      # Each project
      user.projects.each do |project|
        # Non Billed hours
        non_billed = project.time_entries.find_all_by_user_id_and_vendor_invoice_id(user.id, nil).collect(&:hours).reject {|i| i.nil?}.sum
        non_billed ||= 0.0

        # Amount
        membership = Member.find_by_user_id_and_project_id(user.id, project.id)
        rate = membership.rate unless membership.nil? || !membership.respond_to?(:rate)
        rate ||= 0.0

        totals[user.name] += (rate * non_billed).round(Precision)
      end
    end
    
    return totals.sort
  end
end
