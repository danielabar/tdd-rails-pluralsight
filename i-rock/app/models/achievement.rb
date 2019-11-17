# frozen_string_literal: true

# The Achievement model
class Achievement < ActiveRecord::Base
  enum privacy: %i[public_access private_access friends_acceess]
end
