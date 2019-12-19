require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  # support referencing app route urls in tests
  include Rails.application.routes.url_helpers

  let(:achievement_id) { 1 }
  # This is how mailer is used in production code as well
  let(:email) { UserMailer.achievement_created('author@email.com', achievement_id).deliver_now }

  it 'sends achievement created email to author' do
    expect(email.to).to include('author@email.com')
  end

  it 'has correct subject' do
    expect(email.subject).to eq('Congratulations with your new achievement!')
  end

  it 'has achievement link in body message' do
    expect(email.body.to_s).to include(achievement_url(achievement_id))
  end
end
