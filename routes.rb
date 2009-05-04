resources(:accounts_payables,
          :collection => {
            :context_menu => :post,
            :bulk_edit => :get,
            :bulk_update => :put,
            :auto_complete_for_vendor_invoice_number => :get,
            :timesheet => :get,
            :update_time_entries => :put,
            :unbilled_po => :get,
            :unspent_labor => :get,
            :unbilled_labor => :get,
            :time_counter => :get,
            :filter => :post
          })
