class LoadPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    dispatcher?
  end

  def update?
    dispatcher?
  end

  def destroy?
    dispatcher?
  end

  class Scope
    delegate :dispatcher?, to: :user
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if dispatcher?
        scope.all
      else
        scope.joins(:truck).where(trucks: { user_id: user.id })
      end
    end
  end
end
