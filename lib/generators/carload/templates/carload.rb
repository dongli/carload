Carload.setup do |config|
  # Set the title that will be displayed on the browser tab area.
  config.page.title = nil

  # Set the footer text that will be displayed on each page.
  config.page.footer = nil

  # Set the colors of page elements.
  config.page.main_color = nil
  config.page.text_color = 'black'
  config.page.button_color = nil
  config.page.button_text_color = nil

  # Specify which authentication solution is used. Currently, we only support Devise.
  config.auth_solution = :devise

  # Specify which file upload solution is used. Currently, we only support Carrierwave.
  config.upload_solution = :carrierwave

  # Set the actions used to discern user's permission to access dashboard.
  #
  #   config.dashboard.permits_user.<method> = '...'
  #
  # There are four access methods can be configured:
  #
  #   index, new, edit, destroy
  #
  # Also you can use a special method 'all' to set the default permission.
  # The permission can also be array, the relation among them is OR.
  # By doing this, you have full control on the access permission.
  # TODO: Set the permissions for each data table.
  config.dashboard.permits_user.all = 'role.admin?'
end
