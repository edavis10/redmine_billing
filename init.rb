require 'redmine'

# Hooks
require_dependency 'billing_routing_hooks'

Redmine::Plugin.register :redmine_billing do
  name 'Redmine Billing plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  permission(:use_vendor_invoices, { :vendor_invoices => [:index, :show, :new, :create, :edit, :update, :destroy] })

  menu :top_menu, :vendor_invoices, {:controller => 'vendor_invoices', :action => 'index'}, :caption => :list_vendor_invoices
end
