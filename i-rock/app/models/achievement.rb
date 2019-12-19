# frozen_string_literal: true

# The Achievement model
class Achievement < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
  validates :user, presence: true
  validates :title, uniqueness: {
    scope: :user_id,
    message: "you can't have two achievements with the same title"
  }

  enum privacy: %i[public_access private_access friends_acceess]

  mount_uploader :cover_image, CoverImageUploader

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end

  def silly_title
    "#{title} by #{user.email}"
  end

  def self.by_letter(letter)
    includes(:user).where('title LIKE ?', "#{letter}%").order('users.email')
  end

  def self.get_public_achievements
  end
end
