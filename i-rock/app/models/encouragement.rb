class Encouragement < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement

  validates :message, presence: true
end
