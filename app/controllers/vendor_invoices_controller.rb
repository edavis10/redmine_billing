class VendorInvoicesController < ApplicationController
  before_filter :load_vendor_invoice, :only => [ :show, :edit, :update, :destroy ]
  before_filter :load_vendor_invoices, :only => [ :index ]
  before_filter :new_vendor_invoice, :only => [ :new ]
  before_filter :create_vendor_invoice, :only => [ :create ]
  before_filter :update_vendor_invoice, :only => [ :update ]
  before_filter :destroy_vendor_invoice, :only => [ :destroy ]

  protected
  def load_vendor_invoice
    @vendor_invoice = VendorInvoice.find(params[:id])
  end

  def new_vendor_invoice
    @vendor_invoice = VendorInvoice.new
  end

  def create_vendor_invoice
    @vendor_invoice = VendorInvoice.new(params[:vendor_invoice])
    @created = @vendor_invoice.save
  end

  def update_vendor_invoice
    @updated = @vendor_invoice.update_attributes(params[:vendor_invoice])
  end

  def destroy_vendor_invoice
    @vendor_invoice = @vendor_invoice.destroy
  end

  def load_vendor_invoices
    @vendor_invoices = VendorInvoice.find(:all)
  end

  public
  def index
    respond_to do |format|
      format.html
      format.xml  { render :xml => @vendor_invoices }
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
        format.html { redirect_to @vendor_invoice }
        format.xml  { render :xml => @vendor_invoice, :status => :created, :location => @vendor_invoice }
        format.js
      else
        format.html { render :action => :new }
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

  def update
    respond_to do |format|
      if @updated
        flash[:notice] = 'Vendor invoice was successfully updated.'
        format.html { redirect_to @vendor_invoice }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @vendor_invoice.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy          
    respond_to do |format|
      format.html { redirect_to :action => vendor_invoices_url }
      format.xml  { head :ok }
      format.js
    end
  end
end

