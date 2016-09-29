class DashboardPolicy < Struct.new(:user, :dashboard)
  [:index, :new, :edit, :destroy].each do |action|
    define_method :"#{action}?" do
      return false if not user
      action = :all if not Carload.dashboard[:permits_user][action]
      Array(Carload.dashboard[:permits_user][action]).each do |permission|
        return true if eval "user.#{permission}"
      end
      false
    end
  end

  def create?
    new?
  end

  def update?
    edit?
  end
end
