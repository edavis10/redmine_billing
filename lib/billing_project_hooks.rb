class BillingProjectHooks < Redmine::Hook::ViewListener

  def view_projects_form(context = { })
    return content_tag(:p, context[:form].text_field(:total_value))
  end
end
