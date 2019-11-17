# frozen_string_literal: true

require 'rails_helper'

feature 'create new achievement' do
  scenario 'create new achievement with valid data' do
    visit('/')
    # capybara helper method that clicks on button or link with given label
    click_on('New Achievement')

    # fill out form
    # fill_in text helper can be used to fill out text inputs and textareas
    fill_in('Title', with: 'Read a book')
    fill_in('Description', with: 'Excellent read')
    # select privacy setting
    select('Public', from: 'Privacy')
    # checkbox (check/uncheck helper methods)
    check('Featured achievement')
    # upload a file
    attach_file('Cover image', "#{Rails.root}/spec/fixtures/cover_image.png")
    click_on('Create Achievement')

    # Assertions
    expect(page).to have_content('Achievement has been created')
    expect(Achievement.last.title).to eq('Read a book')
  end

  scenario 'cannot create achievement with invalid data' do
    visit('/')
    click_on('New Achievement')
    click_on('Create Achievement')
  end
end
