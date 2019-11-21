# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    sequence(:title) { |n| "Achievement #{n}"}
    description { 'description' }
    privacy { Achievement.privacies[:private_access] }
    featured { false }
    cover_image { 'some_file.png' }
  end

  factory :public_achievement do
    privacies { Achievement.privacies[:public_access] }
  end
end
