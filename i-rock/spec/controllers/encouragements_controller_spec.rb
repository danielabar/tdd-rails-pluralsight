require 'rails_helper'

RSpec.describe EncouragementsController do
  let(:user) { FactoryBot.create(:user) }
  let(:author) { FactoryBot.create(:user) }
  let(:achievement) { FactoryBot.create(:public_achievement, user: author) }

  describe 'GET new' do
    context 'guest user' do
      it 'is redirected back to achievement page' do
        get :new, achievement_id: achievement.id
        expect(response).to redirect_to(achievement_path(achievement))
      end

      it 'assigns flash message' do
        get :new, achievement_id: achievement.id
        expect(flash[:alert]).to eq('You must be logged in to encourage people')
      end
    end

    context 'authenticated user' do
      before { sign_in(user) }

      it 'renderes :new template' do
        get :new, achievement_id: achievement.id
        expect(response).to render_template(:new)
      end

      it 'assigns new encouragement to template' do
        get :new, achievement_id: achievement.id
        expect(assigns(:encouragement)).to be_a_new(Encouragement)
      end
    end

    context 'achievement author' do
      before { sign_in(author)  }

      it 'is redirected back to achievement page' do
        get :new, achievement_id: achievement.id
        expect(response).to redirect_to(achievement_path(achievement))
      end

      it 'assigns flash message' do
        get :new, achievement_id: achievement.id
        expect(flash[:alert]).to eq("You can't encourage yourself")
      end
    end

    context 'user who already left encouragement for this achievement' do
      before do
        sign_in(user)
        FactoryBot.create(:encouragement, user: user, achievement: achievement)
      end

      it 'is redirected back to achievement page' do
        get :new, achievement_id: achievement.id
        expect(response).to redirect_to(achievement_path(achievement))
      end

      it 'assigns flash message' do
        get :new, achievement_id: achievement.id
        expect(flash[:alert]).to eq("You already encouraged it. You can't be so generous!")
      end
    end
  end
end
