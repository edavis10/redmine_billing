require 'redmine'

# Hooks
require_dependency 'billing_routing_hooks'

# Patches
require_dependency 'billing_user_patch'

Redmine::Plugin.register :redmine_billing do
  name 'Redmine Billing plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  permission(:use_accounts_payable, { :accounts_payables => [:index, :show, :new, :create, :edit, :update, :destroy, :context_menu, :bulk_edit] })

  menu :top_menu, :accounts_payables, {:controller => 'accounts_payables', :action => 'index'}, :caption => :accounts_payable_menu, :if => Proc.new{User.current.logged?} 
end
