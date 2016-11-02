class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  USER_ROLES = %w(driver dispatcher).freeze

  validates :login, presence: true, uniqueness: true
  validates :role, inclusion: { in: USER_ROLES }

  # Hacking devise to use login instead of email
  def email_required?
    false
  end

  def email_changed?
    false
  end
end
