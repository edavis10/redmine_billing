module VendorInvoicesHelper
  def vendor_invoice_number_for(invoice)
    link_to invoice.number, accounts_payable_path(invoice), :class => (invoice.billing_status.nil? ? '': 'billing-status-' + invoice.billing_status)
  end
  
  def bulk_edit_list_for_vendor_invoices(invoices)
    invoices.collect do |i|
      content_tag('li',
                  link_to(h("#{i.number}"), accounts_payable_path(i))) 
    end.join("\n")
  end
end
