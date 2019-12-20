require 'rails_helper'

RSpec.describe 'Achievements API', type: :request do
  let(:user) { FactoryBot.create(:user) }

  it 'sends public achievements' do
    # setup: create some achievements in db to be returned by api or not
    public_achievement = FactoryBot.create(:public_achievement, title: 'My achievement', user: user)
    private_achievement = FactoryBot.create(:private_achievement, user: user)

    get '/api/achievements', nil, 'Content-Type': 'application/vnd.api+json'

    expect(response.status).to eq(200)
    json = JSON.parse(response.body)

    expect(json['data'].count).to eq(1)
    expect(json['data'][0]['type']).to eq('achievements')
    expect(json['data'][0]['attributes']['title']).to eq('My achievement')
  end
end
