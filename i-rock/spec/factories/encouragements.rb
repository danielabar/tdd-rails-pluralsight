FactoryBot.define do
  factory :encouragement do
    user
    achievement
    message { 'MyString' }
  end
end
