require File.dirname(__FILE__) + '/../spec_helper'

# just enough infrastructure to get 'assert_select' to work
require 'action_controller'
require 'action_controller/assertions/selector_assertions'
include ActionController::Assertions::SelectorAssertions

def call_hook(method, context = {})
  return BillingTimesheetHooks.instance.send(method, context)
end

describe BillingTimesheetHooks, '#plugin_timesheet_views_timesheet_group_header' do
  it 'should render the invoice table headers' do
    response = call_hook(:plugin_timesheet_views_timesheet_group_header)
    response.should have_tag("th","Invoice")
  end
end

describe BillingTimesheetHooks, '#plugin_timesheet_views_timesheet_time_entry' do
  it 'should render a invoice cell showing the invoice number for the time_entry' do
    BillingTimesheetHooks.instance.should_receive(:invoice_cell).and_return('')
    call_hook(:plugin_timesheet_views_timesheet_time_entry,
              { :time_entry => mock_model(TimeEntry) })
  end
end

describe BillingTimesheetHooks, '#plugin_timesheet_views_timesheet_time_entry_sum' do
  it 'should render a cost cell totaling the costs for all the time_entries' do
    # User is allowed access
    project = mock_model(Project)
    current_user = mock_model(User, :logged? => true)
    current_user.stub!(:allowed_to?).with(:view_rate, project).and_return(true)
    User.stub!(:current).and_return(current_user)

    te_1 = mock_model(TimeEntry, :project => project, :cost => 100.00)
    te_2 = mock_model(TimeEntry, :project => project, :cost => 100.00)
    te_3 = mock_model(TimeEntry, :project => project, :cost => nil)
    time_entries = [te_1, te_2, te_3]

    BillingTimesheetHooks.instance.stub!(:td_cell).with("&nbsp;").and_return("")

    BillingTimesheetHooks.instance.should_receive(:td_cell).
      with("$200.00").
      and_return('<td>$200.00</td>')

    call_hook(:plugin_timesheet_views_timesheet_time_entry_sum,
              {:time_entries => time_entries})
  end

  it 'should render an empty invoice cell' do
    BillingTimesheetHooks.instance.stub!(:td_cell).with("$0.00").and_return("")
    BillingTimesheetHooks.instance.should_receive(:td_cell).
      with("&nbsp;").
      and_return('<td>&nbsp;</td>')
    call_hook(:plugin_timesheet_views_timesheet_time_entry_sum,
              {:time_entries => []})
  end
end

describe BillingTimesheetHooks, '#cost_cell' do
  describe 'for a user without rate access' do

    it 'should render an empty table cell' do
      User.stub!(:current).and_return(mock_model(AnonymousUser, :logged? => false))
      response = call_hook(:cost_cell, mock_model(TimeEntry))
      response.should have_tag("td", "&nbsp;")
    end

  end

  describe 'for a user with rate access' do
    before(:each) do
      @project = mock_model(Project)
      @time_entry = mock_model(TimeEntry, :project => @project, :cost => 100.00)
      @current_user = mock_model(User, :logged? => true)
      @current_user.stub!(:allowed_to?).
        with(:view_rate, @project).
        and_return(true)
      User.stub!(:current).and_return(@current_user)
    end
    
    it 'should render a table cell' do
      response = call_hook(:cost_cell, @time_entry)
      response.should have_tag("td")
    end
    
    it 'should have the cost formatted as a currency' do
      response = call_hook(:cost_cell, @time_entry)
      response.should have_tag("td", "$100.00")
    end
  end
end

describe BillingTimesheetHooks, '#invoice_cell' do
  describe 'for a user without accounts payable access' do

    it 'should render an empty table cell' do
      User.stub!(:current).and_return(mock_model(AnonymousUser, :logged? => false))
      response = call_hook(:invoice_cell, mock_model(TimeEntry))
      response.should have_tag("td", "&nbsp;")
    end

  end

  describe 'for a user with accounts payable access' do
    before(:each) do
      @current_user = mock_model(User, :logged? => true)
      @current_user.stub!(:allowed_to?).
        with(:use_accounts_payable, nil, :global => true).
        and_return(true)
      User.stub!(:current).and_return(@current_user)
    end
    
    describe 'with a vendor invoice' do
      before(:each) do
        @vendor_invoice = mock_model(VendorInvoice, :number => 'T42', :id => 10)
        @time_entry = mock_model(TimeEntry, :vendor_invoice => @vendor_invoice)
      end

      it 'should render a table cell' do
        response = call_hook(:invoice_cell, @time_entry)
        response.should have_tag("td")
      end
      
      it 'should have a link to the invoice' do
        response = call_hook(:invoice_cell, @time_entry)
        response.should have_tag("a[href*=?]", "accounts_payable")
        response.should have_tag("a[href*=?]", "10")
      end

      it 'should show the invoice number' do
        response = call_hook(:invoice_cell, @time_entry)
        response.should match(/#{@vendor_invoice.number}/i)
      end

    end

    describe 'without a vendor invoice' do
      it 'should render an empty table cell' do
        time_entry = mock_model(TimeEntry, :vendor_invoice => nil)

        response = call_hook(:invoice_cell, time_entry)
        response.should have_tag("td", "&nbsp;")
      end
    end
  end
end

