# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }

    it {
      should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("can't be blank")
                                           .with_message("you can't have two achievements with the same title")
    }

    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  it 'converts markdown to html' do
    achievement = Achievement.new(description: 'Awesome **thing** I *actually* did')
    expect(achievement.description_html).to include('<strong>thing</strong>')
    expect(achievement.description_html).to include('<em>actually</em>')
  end

  it 'has silly title' do
    achievement = Achievement.new(title: 'New Achievement', user: FactoryBot.create(:user, email: 'test@test.com'))
    expect(achievement.silly_title).to eq('New Achievement by test@test.com')
  end

  it 'only fetches achievemetns which title starts from provided letter' do
    user = FactoryBot.create(:user)
    achievement1 = FactoryBot.create(:public_achievement, title: 'Read a book', user: user)
    FactoryBot.create(:public_achievement, title: 'Passed an exam', user: user)
    expect(Achievement.by_letter('R')).to eq([achievement1])
  end

  it 'sorts achievements by user emails' do
    albert = FactoryBot.create(:user, email: 'albert@email.com')
    rob = FactoryBot.create(:user, email: 'rob@email.com')
    achievement1 = FactoryBot.create(:public_achievement, title: 'Read a book', user: rob)
    achievement2 = FactoryBot.create(:public_achievement, title: 'Rocked it', user: albert)
    expect(Achievement.by_letter('R')).to eq([achievement2, achievement1])
  end
end
