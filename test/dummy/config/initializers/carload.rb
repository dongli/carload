Carload.setup do |config|
  # Specify which authentication solution is used. Currently, we only support Devise.
  config.auth_solution = :devise

  # Set the actions used to discern user's permission to access dashboard.
  # Note: This will be evaluated as eval("user.#{Carload.dashboard.permitted_user.all}").
  config.dashboard.permits_user.all = 'role.admin?'
  config.dashboard.permits_user.index = [ 'role.user?', 'role.admin?' ]
  config.dashboard.permits_user.new = 'role.user?'
end
