require 'test_helper'

class TimesheetIntegrationTest < ActionController::IntegrationTest

  context "submitting the timesheet" do
    setup do
      @project = Project.generate!(:identifier => 'main')
      @role = Role.generate!
      @user = User.generate!(:password => 'billing', :password_confirmation => 'billing', :admin => true)

      # generate_vendor_invoices
      BillingStatus.names.each do |status|
        invoice = HourlyVendorInvoice.generate!(:billing_status => status.to_s, :number => status.to_s)

        # sets @status_invoice ivars to reference later
        ivar_name = "@#{status}_invoice" 
        instance_variable_set(ivar_name, invoice)
                              
        TimeEntry.generate!(:user => @user,
                            :project => @project,
                            :hours => 5,
                            :comments => "Time logged on #{status.to_s}",
                            :spent_on => Date.today,
                            :vendor_invoice => invoice)
      end

      TimeEntry.generate!(:user => @user,
                          :project => @project,
                          :hours => 5,
                          :comments => "Time logged without invoice",
                          :spent_on => Date.today,
                          :vendor_invoice => nil)
      
      User.add_to_project(@user, @project, @role)
    
      login_as(@user.login, 'billing')
      click_link 'Timesheet'
    end
    
    context "with the predefined billing status group" do
      setup do
        choose('timesheet_billing_status_type_1')
      end
      
      context "'Any'" do
        should "show time for all billing statuses" do
          select('Any', :from => 'timesheet_billing_status_group')
          click_button 'Apply'

          assert has_content?("Time logged without invoice")
          assert has_content?("Time logged on unbilled")
          assert has_content?("Time logged on billed")
          assert has_content?("Time logged on approved")
          assert has_content?("Time logged on paid")
          assert has_content?("Time logged on hold")
          assert has_content?("Time logged on rejected")
          assert has_content?("Time logged on pro_bono")
          assert has_content?("Time logged on internal")
        end
        
      end
      
      context "'Invoiced'" do
        should "show time on vendor invoices only" do
          select('Invoiced', :from => 'timesheet_billing_status_group')
          click_button 'Apply'

          assert has_content?("Time logged on unbilled")
          assert has_content?("Time logged on billed")
          assert has_content?("Time logged on approved")
          assert has_content?("Time logged on paid")
          assert has_content?("Time logged on hold")
          assert has_content?("Time logged on rejected")
          assert has_content?("Time logged on pro_bono")
          assert has_content?("Time logged on internal")
          assert has_no_content?("Time logged without invoice")
        end
      end

      context "'Not Invoiced'" do
        should "show time without a vendor invoice" do
          select('Not invoiced', :from => 'timesheet_billing_status_group')
          click_button 'Apply'

          assert has_content?("Time logged without invoice")
          assert has_no_content?("Time logged on unbilled")
          assert has_no_content?("Time logged on billed")
          assert has_no_content?("Time logged on approved")
          assert has_no_content?("Time logged on paid")
          assert has_no_content?("Time logged on hold")
          assert has_no_content?("Time logged on rejected")
          assert has_no_content?("Time logged on pro_bono")
          assert has_no_content?("Time logged on internal")
          
        end
        
      end
    end
    
    context "with specific billing statuses" do
      setup do
        choose('timesheet_billing_status_type_2')
      end

      should "only show time entries for those statuses" do
        select('Approved', :from => 'timesheet_billing_status_')
        select('Paid', :from => 'timesheet_billing_status_')
        click_button 'Apply'

        assert has_content?("Time logged on approved")
        assert has_content?("Time logged on paid")

        assert has_no_content?("Time logged on unbilled")
        assert has_no_content?("Time logged on billed")
        assert has_no_content?("Time logged on hold")
        assert has_no_content?("Time logged on rejected")
        assert has_no_content?("Time logged on pro_bono")
        assert has_no_content?("Time logged on internal")
        assert has_no_content?("Time logged without invoice")

      end

      should "show all time entries if the statuses are empty" do
        click_button 'Apply'

        assert has_content?("Time logged on approved")
        assert has_content?("Time logged on paid")
        assert has_content?("Time logged on unbilled")
        assert has_content?("Time logged on billed")
        assert has_content?("Time logged on hold")
        assert has_content?("Time logged on rejected")
        assert has_content?("Time logged on pro_bono")
        assert has_content?("Time logged on internal")
        assert has_content?("Time logged without invoice")

      end

    end
    
  end
  
end
