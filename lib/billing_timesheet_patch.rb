require_dependency 'timesheet'

# Patches Timesheets dynamically.
module BillingTimesheetPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      attr_accessor :vendor_invoice
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

# Add module
Timesheet.send(:include, BillingTimesheetPatch)


