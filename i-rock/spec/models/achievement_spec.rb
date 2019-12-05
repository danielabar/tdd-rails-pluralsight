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
end
