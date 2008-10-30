class AccountsPayablesController < ApplicationController
  unloadable
  layout 'base'
  # Redmine fitlers
  before_filter :authorize

  before_filter :load_vendor_invoice, :only => [ :show, :edit, :update, :destroy, :update_time_entries ]
  before_filter :load_vendor_invoices, :only => [ :bulk_edit, :bulk_update ]
  before_filter :load_all_vendor_invoices, :only => [ :timesheet ]
  before_filter :new_vendor_invoice, :only => [ :new ]
  before_filter :create_vendor_invoice, :only => [ :create ]
  before_filter :update_vendor_invoice, :only => [ :update ]
  before_filter :update_vendor_invoices, :only => [ :bulk_update ]
  before_filter :load_vendor_invoice_filter, :only => [ :index ]

  helper :vendor_invoices

  protected
  def load_vendor_invoice
    @vendor_invoice = VendorInvoice.find(params[:id])
  end

  def load_vendor_invoices
    @vendor_invoices = VendorInvoice.find_all_by_id(params[:ids])
  end

  def load_all_vendor_invoices
    @vendor_invoices = VendorInvoice.find(:all)
  end

  def new_vendor_invoice
    @vendor_invoice = VendorInvoice.new
    @vendor_invoice.time_entry_ids = params[:time_entry_ids] unless params[:time_entry_ids].nil?
  end

  def create_vendor_invoice
    @vendor_invoice = VendorInvoice.new(params[:vendor_invoice])
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
    if params && params[:vendor_invoice_filter]
      @vendor_invoice_filter = VendorInvoiceFilter.new( params[:vendor_invoice_filter] )
    else
      @vendor_invoice_filter = VendorInvoiceFilter.new
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
      format.html
      format.xml  { render :xml => @users.collect(&:vendor_invoices) }
      format.js
    end
  end

  def show          
    respond_to do |format|
      format.html
      format.xml  { render :xml => @vendor_invoice }
      format.js
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
    @vendor_invoices = VendorInvoice.find(:all, :conditions => [ "LOWER(number) LIKE ?", '%' + params[:time_entry][:vendor_invoice_number].downcase + '%' ])
    render :partial => 'autocomplete.html.erb'
  end
  
  def timesheet
    @time_entries = params[:time_entry_ids]
    render :layout => false
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

  private
  
  # Override the default authorize and add in the global option. This will allow
  # the user in if they have any roles with the correct permission
  def authorize(ctrl = params[:controller], action = params[:action])
    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, nil, { :global => true})
    allowed ? true : deny_access
  end
  
  def allowed_projects
    if User.current.admin?
      return Project.find(:all, :order => 'name ASC')
    else
      return User.current.projects.find(:all, :order => 'name ASC')
    end
  end
end

