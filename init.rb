require 'redmine'
require 'fastercsv'

# Plugins
Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

# AutoComplete
require File.join(directory,'vendor','plugins','auto_complete','init')

# Hooks
require_dependency 'billing_routing_hooks'
require_dependency 'billing_timelog_hooks'
require_dependency 'billing_timesheet_hooks'
require_dependency 'billing_project_hooks'

# Patches
require_dependency 'billing_user_patch'
require_dependency 'billing_time_entry_patch'
require_dependency 'billing_timesheet_patch'

Redmine::Plugin.register :redmine_billing do
  name 'Redmine Billing plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.3.0'

  permission(:use_accounts_payable, {
               :accounts_payables => [
                                      :auto_complete_for_vendor_invoice_number,
                                      :bulk_edit,
                                      :bulk_update,
                                      :context_menu,
                                      :create,
                                      :destroy,
                                      :edit,
                                      :filter,
                                      :index,
                                      :new,
                                      :time_counter,
                                      :timesheet,
                                      :unbilled_labor,
                                      :unbilled_po,
                                      :unspent_labor,
                                      :update,
                                      :update_time_entries
                                     ] })

  # Allows a user to see all invoices for the project they have this Role+Permission on
  permission :all_invoices_on_project, { }
  
  menu(:top_menu,
       :accounts_payables,
       {
         :controller => 'accounts_payables',
         :action => 'index'
       },
       :caption => :accounts_payable_menu,
       :if => Proc.new {
         User.current.logged? &&
         User.current.allowed_to?(:use_accounts_payable, nil, :global => true)
       })
end

begin
  require_dependency 'budget' unless Object.const_defined?('Budget')
rescue LoadError
  # budget_plugin is not installed
end

begin
  require_dependency 'rate' unless Object.const_defined?('Rate')
rescue LoadError
  # rate_plugin is not installed
  raise Exception.new("ERROR: The Rate plugin is not installed.  Please install the Rate plugin or downgrade to version 0.2.0 of the Billing plugin.")
end
