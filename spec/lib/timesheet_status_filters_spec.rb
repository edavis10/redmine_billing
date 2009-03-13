require File.dirname(__FILE__) + '/../spec_helper'

def call_hook(method, context = {})
  return BillingTimesheetHooks.instance.send(method, context)
end

describe BillingTimesheetHooks, "#plugin_timesheet_model_timesheet_conditions" do
  it 'should add the billing statuses to the conditions' do
    timesheet = mock('Timesheet')
    timesheet.stub!(:vendor_invoice).and_return(nil)
    timesheet.stub!(:billing_statuses).and_return(["paid","unpaid"])

    conditions = ['']

    call_hook(:plugin_timesheet_model_timesheet_conditions,
              { :timesheet => timesheet, :conditions => conditions })
    conditions.length.should eql(2)
    conditions[0].should match(/billing_status IN/i)
    conditions[1].should eql(["paid","unpaid"])
  end

  it 'should not change the conditions when there are no billing statuses' do
    timesheet = mock('Timesheet')
    timesheet.stub!(:vendor_invoice).and_return(nil)
    timesheet.stub!(:billing_statuses).and_return(nil)
    conditions = ['']

    proc {
      call_hook(:plugin_timesheet_model_timesheet_conditions,
                { :timesheet => timesheet, :conditions => conditions })
    }.should_not change(conditions, :length)
  end
end

describe BillingTimesheetHooks, "#plugin_timesheet_model_timesheet_includes" do
  it 'should add the Vendor Invoices table when there are billing statuses' do
    timesheet = mock('Timesheet')
    timesheet.stub!(:vendor_invoice).and_return(nil)
    timesheet.stub!(:billing_statuses).and_return(["paid","unpaid"])

    includes = []

    call_hook(:plugin_timesheet_model_timesheet_includes,
              { :timesheet => timesheet, :includes => includes })

    includes.length.should eql(1)
    includes[0].should eql(:vendor_invoice)
  end

  it 'should not change the includes when there are no billing statuses' do
    timesheet = mock('Timesheet')
    timesheet.stub!(:vendor_invoice).and_return(nil)
    timesheet.stub!(:billing_statuses).and_return(nil)
    includes = []

    call_hook(:plugin_timesheet_model_timesheet_includes,
              { :timesheet => timesheet, :includes => includes })
    includes.should be_empty
  end
end

describe BillingTimesheetHooks, "#plugin_timesheet_view_timesheet_form" do
  it 'should include a select field for Billing Status' do
    response = call_hook(:plugin_timesheet_view_timesheet_form,
                         { :list_size => 10})

    response.should have_tag("select[name=?]", "timesheet[billing_status][]")
  end
end

describe BillingTimesheetHooks, "#plugin_timesheet_controller_report_pre_fetch_time_entries" do
  it 'should set the billing status based on the parameters' do
    timesheet = mock('Timesheet')
    timesheet.should_receive(:billing_statuses=).with(["paid","unpaid"])
    params = { :timesheet => {:billing_status => ["paid", "unpaid"] }}

    call_hook(:plugin_timesheet_controller_report_pre_fetch_time_entries,
              { :timesheet => timesheet, :params => params})
  end
end
# controller
