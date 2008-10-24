require_dependency 'time_entry'

# Patches Redmine's Time Entries dynamically.  Adds a relationship 
# Time Entry belongs to a Vendor Invoice
module BillingTimeEntryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :vendor_invoice
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

# Add module
TimeEntry.send(:include, BillingTimeEntryPatch)


