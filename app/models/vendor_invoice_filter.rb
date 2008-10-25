class VendorInvoiceFilter
  attr_accessor :date_from
  attr_accessor :date_to
  attr_accessor :projects
  attr_accessor :activities
  attr_accessor :users
  attr_accessor :vendor_invoices
  attr_accessor :allowed_projects
  
  def initialize(options = { })
    self.vendor_invoices = options[:vendor_invoices] || { }
    self.projects = [ ]
    self.allowed_projects = options[:allowed_projects] || [ ]

    unless options[:activities].nil?
      self.activities = options[:activities].collect { |a| a.to_i }
    else
      self.activities =  Enumeration::get_values('ACTI').collect(&:id)
    end

    unless options[:users].nil?
      self.users = options[:users].collect { |u| u.to_i }
    else
      self.users = User.find(:all).collect(&:id)
    end

    self.date_from = options[:date_from] || Date.today.to_s
    self.date_to = options[:date_to] || Date.today.to_s
  end
  
  def filter!
    self.vendor_invoices = { }
  end
end
