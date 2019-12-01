# frozen_string_literal: true

# The Achievement model
class Achievement < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true

  enum privacy: %i[public_access private_access friends_acceess]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
