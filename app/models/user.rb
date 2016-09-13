class User < ActiveRecord::Base
  # Remember to create a migration!
  serialize :last_context, JSON

  validates :phone_number, presence: true
  validates :phone_number, uniqueness: true

end
