require 'redmine'

# Plugins
Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path)
end

# AutoComplete
require File.join(directory,'vendor','plugins','auto_complete','init')

# Hooks
require_dependency 'billing_routing_hooks'
require_dependency 'billing_timelog_hooks'
require_dependency 'billing_timesheet_hooks'

# Patches
require_dependency 'billing_user_patch'
require_dependency 'billing_time_entry_patch'

Redmine::Plugin.register :redmine_billing do
  name 'Redmine Billing plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  permission(:use_accounts_payable, { :accounts_payables => [:index, :show, :new, :create, :edit, :update, :destroy, :context_menu, :bulk_edit, :bulk_update, :auto_complete_for_vendor_invoice_number, :timesheet, :update_time_entries] })

  menu :top_menu, :accounts_payables, {:controller => 'accounts_payables', :action => 'index'}, :caption => :accounts_payable_menu, :if => Proc.new{User.current.logged?} 
end
