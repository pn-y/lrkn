class RouteListPolicy < Struct.new(:user, :route_list)
  def index?
    true
  end

  def show?
    true
  end
end
