# Patches Timesheets dynamically.
module BillingTimesheetPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      attr_accessor :vendor_invoice
      attr_accessor :billing_statuses
      attr_accessor :billing_status_type # 0=> named, 1=> by ids
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

