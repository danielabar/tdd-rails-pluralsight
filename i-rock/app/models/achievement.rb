# frozen_string_literal: true

# The Achievement model
class Achievement < ActiveRecord::Base
  validates :title, presence: true
  enum privacy: %i[public_access private_access friends_acceess]
end
