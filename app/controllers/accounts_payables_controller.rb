class AccountsPayablesController < ApplicationController
  unloadable
  layout 'base'
  # Redmine fitlers
  before_filter :authorize, :except => [:show]
  
  include ActionView::Helpers::NumberHelper

  before_filter :load_vendor_invoice, :only => [ :show, :edit, :update, :destroy, :update_time_entries ]
  before_filter :load_vendor_invoices, :only => [ :bulk_edit, :bulk_update ]
  before_filter :load_all_hourly_vendor_invoices, :only => [ :timesheet ]
  before_filter :new_vendor_invoice, :only => [ :new ]
  before_filter :create_vendor_invoice, :only => [ :create ]
  before_filter :update_vendor_invoice, :only => [ :update ]
  before_filter :update_vendor_invoices, :only => [ :bulk_update ]
  before_filter :load_vendor_invoice_filter, :only => [ :index, :filter ]

  helper :vendor_invoices
  helper :timelog

  protected
  def load_vendor_invoice
    @vendor_invoice = VendorInvoice.find(params[:id])
  end

  def load_vendor_invoices
    @vendor_invoices = VendorInvoice.find_all_by_id(params[:ids])
  end

  def load_all_hourly_vendor_invoices
    @vendor_invoices = HourlyVendorInvoice.find(:all)
  end

  def new_vendor_invoice
    if params[:type] && params[:type] == 'hourly'
      @vendor_invoice = HourlyVendorInvoice.new
      unless params[:time_entry_ids].nil?
        @vendor_invoice.time_entry_ids = params[:time_entry_ids]
        @vendor_invoice.set_default_user
      end
    else
      @vendor_invoice = FixedVendorInvoice.new
    end
  end

  def create_vendor_invoice
    if params[:vendor_invoice][:type] == HourlyVendorInvoice.name
      @vendor_invoice = HourlyVendorInvoice.new(params[:vendor_invoice])
    else
      @vendor_invoice = FixedVendorInvoice.new(params[:vendor_invoice])
    end
    @vendor_invoice.time_entry_ids = params[:time_entry_ids] unless params[:time_entry_ids].nil?
    @created = @vendor_invoice.save
  end

  def update_vendor_invoice
    @updated = @vendor_invoice.update_attributes(params[:vendor_invoice])
  end

  def update_vendor_invoices
    @unsaved_ids = []
    @vendor_invoices.each do |vendor_invoice|
      attr = { }
      attr[:invoiced_on] = params[:invoiced_on] unless params[:invoiced_on].nil? || params[:invoiced_on].blank?
      attr[:user_ids] = params[:user_ids] unless params[:user_ids].nil? || params[:user_ids].empty?
      attr[:comment] = params[:comment] unless params[:comment].nil? || params[:comment].blank?
      attr[:billing_status] = params[:billing_status] unless params[:billing_status].nil? || params[:billing_status].blank?
        
      unless vendor_invoice.update_attributes(attr)
        @unsaved_ids << vendor_invoice.id
      end
    end
    
    @updated = @unsaved_ids.empty?
  end

  def load_vendor_invoice_filter
    @free_period = true
    if params && params[:vendor_invoice_filter]
      @vendor_invoice_filter = VendorInvoiceFilter.new( params[:vendor_invoice_filter] )
    else
      @vendor_invoice_filter = VendorInvoiceFilter.new
    end
    
    # Override the range in date_to and date_from if the periods are used
    if params[:period_type] == '1' || (params[:period_type].nil? && !params[:period].nil?)
      @vendor_invoice_filter.period = params[:period].to_s
      @free_period = false
    end
    
    @vendor_invoice_filter.allowed_projects = allowed_projects

    if params && params[:vendor_invoice_filter] && !params[:vendor_invoice_filter][:projects].blank?
      @vendor_invoice_filter.projects = @vendor_invoice_filter.allowed_projects.find_all do |project| 
        params[:vendor_invoice_filter][:projects].include?(project.id.to_s)
      end
    else 
      @vendor_invoice_filter.projects = @vendor_invoice_filter.allowed_projects
    end
    
    @vendor_invoice_filter.filter!
  end

  public
  def index
    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @users.collect(&:vendor_invoices) }
      format.js
    end
  end

  # Similar to index but is filtered via a HTTP POST
  def filter
    index
  end
  
  def show          
    respond_to do |format|
      if allowed_to_view_vendor_invoice?(@vendor_invoice)
        format.html
        format.xml  { render :xml => @vendor_invoice }
        format.js
      else
        format.html { render_403 }
      end
    end
  end

  def new          
    respond_to do |format|
      format.html { render :action => :edit }
      format.xml  { render :xml => @vendor_invoice }
      format.js
    end
  end

  def create
    respond_to do |format|
      if @created
        flash[:notice] = 'Vendor invoice was successfully created.'
        format.html { redirect_to accounts_payable_path(@vendor_invoice) }
        format.xml  { render :xml => @vendor_invoice, :status => :created, :location => @vendor_invoice }
        format.js
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @vendor_invoice.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end 

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def bulk_edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    respond_to do |format|
      if @updated
        flash[:notice] = 'Vendor invoice was successfully updated.'
        format.html { redirect_to accounts_payable_path(@vendor_invoice) }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @vendor_invoice.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def bulk_update
    respond_to do |format|
      if @updated
        flash[:notice] = 'Vendor invoices were successfully updated.'
        format.html { redirect_to accounts_payables_path }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = 'Failed to save some Vendor invoices: #' + @unsaved_ids.join(', #')
        format.html { redirect_to accounts_payables_path }
        format.xml  { head :bad_request }
        format.js
      end
    end
  end
  
  def context_menu
    @vendor_invoices = VendorInvoice.find_all_by_id(params[:ids])
    render :layout => false
  end

  def auto_complete_for_vendor_invoice_number
    @vendor_invoices = VendorInvoice.search_allowed(User.current, params[:time_entry][:vendor_invoice_number].downcase)
    render :partial => 'autocomplete.html.erb'
  end
  
  def timesheet
    @time_entries = params[:time_entry_ids]
    render :layout => false
  end
  
  def time_counter
    respond_to do |format|
      @time_entries = SelectedTimeEntry.find_all_by_id(params[:ids])
      format.json { render :json => @time_entries.to_json}
    end
  end

  def update_time_entries
    respond_to do |format|
      @vendor_invoice.time_entry_ids += params[:time_entry_ids] unless params[:time_entry_ids].empty?
      if @vendor_invoice.save
        flash[:notice] = 'Time Entries were successfully updated.'
        format.html { redirect_to accounts_payables_path }
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = 'Time Entries were not assigned correctly, please try again.'
        format.html { redirect_to accounts_payables_path }
        format.xml  { render :xml => @vendor_invoice.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def unbilled_po
    respond_to do |format|
      format.csv { 
        @data = BillingExport.unbilled_po
        csv_string = FasterCSV.generate do |csv|
          csv << [
                  "Unbilled PO",
                  number_with_precision(@data.collect {|v| v[1].to_f}.sum, 2)
                 ]

          @data.each do |project_name, amount|
            csv << [
                    [project_name],
                    [amount]
                   ]
          end
        end

        send_data(csv_string,
                  :type => 'text/csv; charset=utf-8; header=present',
                  :filename => "unbilled_po.csv")
      }
    end
  end
    
  def unspent_labor
    respond_to do |format|
      format.csv { 
        @data = BillingExport.unspent_labor
        csv_string = FasterCSV.generate do |csv|
          csv << [
                  "Unspent Labor Budget",
                  number_with_precision(@data.collect {|v| v[1].to_f}.sum,2)
                 ]

          @data.each do |project_name, amount|
            csv << [
                    [project_name],
                    [amount]
                   ]
          end
        end

        send_data(csv_string,
                  :type => 'text/csv; charset=utf-8; header=present',
                  :filename => "unspent_labor.csv")
      }
    end
  end

  # Labor done by members that are not invoiced yet
  def unbilled_labor
    respond_to do |format|
      format.csv { 
        @data = BillingExport.unbilled_labor
        csv_string = FasterCSV.generate do |csv|
          csv << [
                  "Unbilled Labor",
                  @data.collect {|v| v[1]}.sum
                 ]

          @data.each do |project_name, amount|
            csv << [
                    [project_name],
                    [amount]
                   ]
          end
        end

        send_data(csv_string,
                  :type => 'text/csv; charset=utf-8; header=present',
                  :filename => "unbilled_labor.csv")
      }
    end
  end

  private
  
  # Override the default authorize and add in the global option. This will allow
  # the user in if they have any roles with the correct permission
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, nil, { :global => true})
    allowed ? true : deny_access
  end
  
  def allowed_to_view_vendor_invoice?(vendor_invoice)
    # Allow if given :use_accounts_payable permission
    return true if VendorInvoice.allowed_to_use_accounts_payable?(User.current)

    # Allow if the user is assigned
    return true if !vendor_invoice.users.nil? && @vendor_invoice.users.include?(User.current)
    
    # Deny rest
    return false
  end
  
  def allowed_projects
    if User.current.admin?
      return Project.find(:all, :order => 'name ASC')
    else
      return User.current.projects.find(:all, :order => 'name ASC')
    end
  end
end

