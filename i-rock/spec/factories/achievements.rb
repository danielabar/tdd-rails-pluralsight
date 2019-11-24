# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    sequence(:title) { |n| "Achievement #{n}" }
    description { 'description' }
    featured { false }
    cover_image { 'some_file.png' }

    factory :public_achievement do
      privacy { :public_access }
    end

    factory :private_achievement do
      privacy { :private_access }
    end
  end
end
