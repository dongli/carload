require_relative 'devise'

Carload.setup do |config|
  # Set the title that will be displayed on the browser tab area.
  config.page.title = 'Carload Test'

  # Set the footer text that will be displayed on each page.
  config.page.footer = nil

  # Set the colors of page elements.
  config.page.main_color = nil
  config.page.text_color = 'black'
  config.page.button_color = nil
  config.page.button_text_color = nil

  # Set which authentication solution is used. Currently, we only support Devise.
  config.auth_solution = :none

  # Set which file upload solution is used. Currently, we only support Carrierwave.
  config.upload_solution = :carrierwave

  # Set the actions used to discern user's permission to access dashboard.
  # Note: This will be evaluated as eval("user.#{Carload.dashboard.permitted_user.all}").
  config.dashboard.permits_user.all = 'role.admin?'
end
