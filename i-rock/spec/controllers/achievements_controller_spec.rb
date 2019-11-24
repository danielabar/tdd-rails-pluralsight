# frozen_string_literal: true

require 'rails_helper'

describe AchievementsController, type: :controller do
  describe 'GET new' do
    it 'renders :new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'assigns new Achievement to @achievement' do
      get :new
      expect(assigns(:achievement)).to be_a_new(Achievement)
    end
  end

  describe 'GET show' do
    let(:achievement) { FactoryBot.create(:public_achievement) }
    it 'renders :show template' do
      get :show, id: achievement.id
      expect(response).to render_template(:show)
    end

    it 'assigns requested achievement to @achievement' do
      get :show, id: achievement.id
      # instance variable populated in `show` action should be the same as what was just created in test
      expect(assigns(:achievement)).to eq(achievement)
    end
  end

  describe 'POST create' do
    context 'valid data' do
      let(:valid_data) { FactoryBot.attributes_for(:public_achievement) }

      it 'redirects to achievements#show' do
        post :create, achievement: valid_data
        expect(response).to redirect_to(achievement_path(assigns[:achievement]))
      end

      it 'creates new achievement in database' do
        expect {
          post :create, achievement: valid_data
        }.to change(Achievement, :count).by(1)
      end
    end

    context 'invalid data' do
      let(:invalid_data) { FactoryBot.attributes_for(:public_achievement, title: '') }

      it 'renders :new  template' do
        post :create, achievement: invalid_data
        expect(response).to render_template(:new)
      end

      it 'does not create new achievement in the database' do
        expect {
          post :create, achievement: invalid_data
        }.not_to change(Achievement, :count)
      end
    end
  end
end
