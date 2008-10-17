class BillingRoutingHook  < Redmine::Hook::Listener
  def routes(context={ })
    context[:map].from_plugin :billing_plugin
  end
end
