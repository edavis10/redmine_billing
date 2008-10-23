require_dependency 'user'

# Patches Redmine's Users dynamically.  Adds a relationship 
# User has and belongs to many Vendor Invoice
module BillingUserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :vendor_invoices, :order => 'invoiced_on'
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

# Add module
User.send(:include, BillingUserPatch)


