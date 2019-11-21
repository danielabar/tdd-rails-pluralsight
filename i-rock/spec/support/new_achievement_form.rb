# frozen_string_literal: true

# Page Object for New Achievement form
class NewAchievementForm
  include Capybara::DSL

  def visit_page
    visit('/')
    # capybara helper method that clicks on button or link with given label
    click_on('New Achievement')
    self
  end

  def fill_in_with(params = {})
    # fill_in text helper can be used to fill out text inputs and textareas
    fill_in('Title', with: params.fetch(:title, 'Read a book'))
    fill_in('Description', with: 'Excellent read')
    # select privacy setting
    select('Public', from: 'Privacy')
    # checkbox (check/uncheck helper methods)
    check('Featured achievement')
    # upload a file
    attach_file('Cover image', "#{Rails.root}/spec/fixtures/cover_image.png")
    self
  end

  def submit
    click_on('Create Achievement')
    self
  end
end
