require 'rails_helper'
require_relative '../support/login_form'
require_relative '../support/achievement_page'
require_relative '../support/encouragement_form'

feature 'create encouragement' do
  let(:user)  { FactoryBot.create(:user) }
  let(:achievement_owner) { FactoryBot.create(:user) }
  let(:achievement) { FactoryBot.create(:achievement, user: achievement_owner) }

  let(:login_form) { LoginForm.new }
  let(:achievement_page) { AchievementPage.new }
  let(:encouragement_form) { EncouragementForm.new }

  scenario 'authenticated user leaves encouragement for achievement' do
    login_form.visit_page.login_as(user)

    achievement_page.visit_page(achievement).encourage
    encouragement_form.leave_encouragement(text: 'You rock!').submit

    expect(page).to have_content("Encouragement left by #{user.email}")
    expect(page).to have_content('You rock!')
    expect(page).to have_css('#encouragement-quantity', text: '1')
  end
end
