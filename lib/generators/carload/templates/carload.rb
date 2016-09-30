Carload.setup do |config|
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
