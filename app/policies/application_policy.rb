class ApplicationPolicy
  delegate :dispatcher?, to: :user, allow_nil: true

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
end
