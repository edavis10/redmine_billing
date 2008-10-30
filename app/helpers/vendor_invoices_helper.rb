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
  
  def user_hours_for_vendor_invoice(invoice, user)
    total = invoice.hours
    return "" if total == 0

    case invoice.users.count
    when 0
      # nothing
      return ""
    when 1
      return total.to_s
    else
      return invoice.hours(user).to_s + ' of ' + total.to_s
    end
  end

  def user_amount_for_vendor_invoice(invoice, user)
    if invoice.fixed?
      return number_to_currency(invoice.amount)
    else
      total = invoice.amount_for_user
      return "" if total == 0
    
      case invoice.users.count
      when 0
        # nothing
        return ""
      when 1
        # One user has all time
        return number_to_currency(total)
      else
        return number_to_currency(invoice.amount_for_user(user)) + ' of ' + number_to_currency(total)
      end
    end
  end
  
  def totals(vendor_invoices)
    total = 0
    open = 0
    vendor_invoices.each do |invoice|
      if invoice.fixed?
        total += invoice.amount
        open += invoice.amount unless invoice.open?
      else
        total += invoice.amount_for_user
        open += invoice.amount_for_user unless invoice.open?
      end
    end
    
    return "Outstanding: " + number_to_currency(open) + " / Total: " + number_to_currency(total)

  end

  def totals_for_user(user, vendor_invoices)
    total = 0
    open = 0
    vendor_invoices.each do |invoice|
      if invoice.fixed?
        total += invoice.amount
        open += invoice.amount unless invoice.open?
      else
        total += invoice.amount_for_user(user)
        open += invoice.amount_for_user(user) unless invoice.open?
      end
    end
    
    return "(" + number_to_currency(open) + "/" + number_to_currency(total) + ")"

  end
end
