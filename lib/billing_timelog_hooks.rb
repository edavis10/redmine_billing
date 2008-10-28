class BillingTimelogHooks < Redmine::Hook::ViewListener
  include AutoCompleteMacrosHelper

  def view_timelog_edit_form_bottom(context={ })
    form = context[:form]

    o = ''
    o << "<p>"
    # Create a text field for vendor_invoice_id
    o << form.text_field(:vendor_invoice_id, :size => 15)
    # Create a autocomplete text field for number
    o << text_field_with_auto_complete(:time_entry,
                                       :vendor_invoice_number,
                                       { :autocomplete => "off", :size => 35, :style => 'display: none;' },
                                       { :url => {
                                           :controller => 'accounts_payables',
                                           :action => 'auto_complete_for_vendor_invoice_number',
                                           :protocol => Setting.protocol,
                                           :host => Setting.host_name
                                         },
                                         :after_update_element => "function(element, value) {  $('time_entry_vendor_invoice_id').value = value.id }"
                                       })
    # Add JS to swap the autocompleter and the plain old HTML
    js = <<EOJS
<script type="text/javascript">
$('time_entry_vendor_invoice_id').hide()
$('time_entry_vendor_invoice_number').show()
</script>
EOJS

    o << js
    o << "</p>"
    return o
  end
end
