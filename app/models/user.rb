# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string
#  token           :string           default("")
#  role            :string
#

class User < ApplicationRecord
  has_secure_password
  has_secure_token
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :first_name, presence: true,
                         length: { minimum: 2 }

  has_many :bookings, dependent: :destroy
  has_many :flights, through: :bookings

  def admin?
    role == 'admin'
  end

  def self.filter(value)
    if value
      where('first_name ILIKE :value or last_name ILIKE :value or email ILIKE :value',
            value: "%#{value}%")
    else
      all
    end
  end

  def self.default_ordering
    'email'
  end
end
