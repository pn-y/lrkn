class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  USER_ROLES = %w(driver dispatcher).freeze

  has_one :truck

  validates :login, presence: true, uniqueness: true
  validates :role, inclusion: { in: USER_ROLES }

  def driver?
    role == 'driver'
  end

  def dispatcher?
    role == 'dispatcher'
  end

  # Hacking devise to use login instead of email
  def email_required?
    false
  end

  def email_changed?
    false
  end
end
