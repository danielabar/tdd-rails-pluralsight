<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Test-driven Rails with RSpec, Capybara, and Cucumber](#test-driven-rails-with-rspec-capybara-and-cucumber)
  - [TDD 101](#tdd-101)
    - [RSpec 101](#rspec-101)
    - [Bowling Game: Kata - Rules](#bowling-game-kata---rules)
    - [Different Types of Tests](#different-types-of-tests)
  - [Acceptance Tests](#acceptance-tests)
    - [Rails Application Setup](#rails-application-setup)
    - [First Feature Spec: Happy Path](#first-feature-spec-happy-path)
    - [First Feature Spec: Sad Path](#first-feature-spec-sad-path)
    - [Page Object Pattern](#page-object-pattern)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Test-driven Rails with RSpec, Capybara, and Cucumber

> My notes from Pluralsight [course](https://app.pluralsight.com/library/courses/test-driven-rails-rspec-capybara-cucumber/table-of-contents) on TDD Rails.

## TDD 101

### RSpec 101

Setup:

```shell
rbenv install 2.3.0
rbenvn local 2.3.0
gem install bundler
touch Gemfile
```

Edit `Gemfile`:

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rspec'
```

```shell
bundle install
bundle exec rspec --init
```

Output:
```shell
create   .rspec
create   spec/spec_helper.rb
```

`.rspec` contains options for rspec. Add line: `--format documentation` to get nicely formatted test output that matches structure of describe/context/it. eg:

```
Playground
  when there are no children
    is quite boring place
    is empty
```

[Example](spec/playground_spec.rb)

- don't need to `require spec_helper` because this is already specified in `.rspec`
- `describe` defines the example group
- `describe` is a method that takes a string argument to describe what's being tested and a block in which test examples are defined
- `it` method used to define examples
- common context between groups of examples should be organized into `context`, which is alias for `describe` but used for gropuing tests that have common contet
- `describe` can also accept a class name instead of a string

To run tests

```shell
bundle exec rspec spec
```

`expect` method is used to make assertions, general usage with `equal` matcher:

```ruby
expect(actual_value).to equal(expected_value)
```

Rspec ships with many built-in matchers, can also define custom matchers. [Docs](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers)

Tests should be structured as: Arrange, Act, Assert, eg:

```ruby
it 'is quite boring place' do
  # Arrange
  playground = Playground.new(0)
  # Act
  mood = playground.mood
  # Assert
  expect(mood).to eq('boring')
end
```

Another useful matcher: `be_empty`, takes everything after `be` prefix, appends question mark to it, and sends it as a message to the object under test, this example expects `playground.empty?` to be truthy:

```ruby
it 'is empty' do
  playground = Playground.new(0)
  expect(playground).to be_empty
end
```

Use `before` method for common setup tasks that should be run before each test within a group (context or describe):

```ruby
require_relative '../lib/playground'

describe Playground do
  context 'when there are no children' do
    before do
      @playground = Playground.new(0)
    end

    it 'is quite boring place' do
      mood = @playground.mood
      expect(mood).to eq('boring')
    end

    it 'is empty' do
      expect(@playground).to be_empty
    end
  end
end
```

Even better than using instance variable is to use `let` method, which takes a symbol, and block. This can replace `before`:

```ruby
require_relative '../lib/playground'

describe Playground do
  context 'when there are no children' do
    let(:playground) { Playground.new(0) }

    it 'is quite boring place' do
      mood = playground.mood
      expect(mood).to eq('boring')
    end

    it 'is empty' do
      expect(playground).to be_empty
    end
  end
end
```

`let`:
- is lazy, block will only be executed first time variable is accessed
- runs block for each example, but only once, caching the result

### Bowling Game: Kata - Rules

Task is to create a class to count and sum scores of bowling game. Store number of knocked down pins for every roll in an array, eg:

```ruby
game = BowlingGame.new

susie_game = [1,4,6,4,5,5,10,0,1,7,3,6,4,10,2,8,6]
peter_game = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

game.rolls(susie_game).score #=> 133
game.rolls(peter_game).score #=> 0
```

**How does scoring work?**

- Game consists of 10 frames.
- In each frame, player gets two rolls to attempt to knock down the 10 pins.
- After two attempts, number of knocked pins are added together to arrive at score for that frame.
- Eg: If in frame 1, player knocks down 1 pin in first roll and 4 pins in second roll - frame score = 1 + 4 = 5.
- Eg: In frame 2, player knocks down 4 pins infirst roll and 5 pins in second roll totalling 9, add to previous frame of 5 to get running total of 14
- BUT also have to consider bonuses
- SPARE: Player knocks down all 10 pins within the two rolls of a frame - then score is 10 for that frame PLUS

Run a particular test:

```shell
bundle exec rspec spec/bowling_game_spec.rb
```

Use `pending` keyword to skip a test:

```ruby
it 'scores a game with spare' do
  pending
  game.pins([4, 6, 5] + [0] * 17)
  expect(game.score).to eq(20)
end
```

### Different Types of Tests

**Unit Tests**

Test classes independently with no other collaborators. Could be Rails model, plain old Ruby object.

**Integration Tests**

Test multiple objects communicating with each other via messages. Could be service object in Rails, using several different ActiveRecord model objects to populate data in db. Slower than unit tests because could be using db.

**Acceptance Tests**

Black box testing, emulate client actions, testing from client perspective. Very slow.

## Acceptance Tests

### Rails Application Setup

Setup rails app, RSpec and Capybara gems.

Instructor using: ruby 2.2.2 and rails 4.2.2.

Scaffold rails app, `-T` to skip creating tests because will do in this course:

```shell
gem install rails -v 4.2.2
rails _4.2.2_ new i-rock -T
bundle _1.17.3_ install
bundle _1.17.3_ exec spring binstub --all
cd i-rock
```

Edit [Gemfile](i-rock/Gemfile) to [downgrade sqlite3](https://github.com/sparklemotion/sqlite3-ruby/issues/249#issuecomment-463288367) and use [puma](https://puma.io/). Also specify test gems;

```ruby
gem 'sqlite3', '1.3.13'

# Use Puma as the app server
gem 'puma'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # More test support
  gem 'spring-commands-rspec'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :test do
  gem 'capybara'
end
```

Update deps in terminal:

```shell
bundle _1.17.3_
```

Generate some files:

```shell
bin/rails g rspec:install
bundle _1.17.3_ exec spring binstub --all
```

**Feature Spec**

[home_page_spec.rb](i-rock/spec/features/home_page_spec.rb)

- First line in any rails spec is `require 'rails_helper'`
- Use BDD style wording - `feature` instead of `describe` and `scenario` instead of `it`
- Inside `scenario`, use `capybara` methods to click, fill out forms, navigate etc.

```ruby
require 'rails_helper'

feature 'home page' do
  scenario 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end
end
```

To run all specs (will fail because no route matches `GET /`)

```shell
bin/rspec
```

**Implement GET / to make test pass**

1. Add welcome route to [routes.rb](i-rock/config/routes.rb)

```ruby
Rails.application.routes.draw do
  root to: 'welcome#index'
end
```

This time when run test, get `uninitialized constant WelcomeController`

2. Create [welcome_controller.rb](i-rock/app/controllers/welcome_controller.rb)

Running test this time get `The action 'index' could not be found for WelcomeController`

3. Define `index` action

```ruby
class WelcomeController < ApplicationController
  def index
  end
end
```

Now get error `ActionView::MissingTemplate:`

4. Define welcome view [index.html.erb](i-rock/app/views/welcome/index.html.erb)

Now get assertion error `expected to find text "Welcome" in ""`

5. Add `Welcome` text to view.

Now test passes.

To see the app so far in browser, start rail server, then open [http://localhost:3000](http://localhost:3000)

```shell
bin/rails s
```

Make welcome page prettier with bootstrap. Add to `Gemfile`:
```ruby
gem 'bootstrap-sass', '~> 3.4.1'
gem 'sassc-rails', '>= 2.1.0'
```

Then add new styles in [main.css.scss](i-rock/app/assets/stylesheets/main.css.scss)

Restart rails server after these changes, refresh browser to see bootstrap styles applied.

### First Feature Spec: Happy Path

Will be using Capybara to navigate pages, fill out forms, etc.

[create_achievement_spec.rb](i-rock/spec/features/create_achievement_spec.rb)

Useful Capybara helpers:

| Helper Example        | Description           |
| ------------- |--------------|
| `visit(/)`      | Navigate to specified url |
| `fill_in('Title', with: 'Read a book')`      | Enter text into a named text input or textarea      |
| `select('Public', from: 'Privacy')` | Select a value from a given dropdown      |
| `check('Featured achievement')` | Check a checkbox, also have `uncheck`      |
| `attach_file('Cover image', "#{Rails.root}/spec/fixtures/cover_image.png")` | Upload a file      |
| `click_on('Create Achievement')` | Click on a button or link with the given label      |

Running tests at this point will fail because haven't created this view yet:

```shell
bin/rspec
```

To implement it, modify [application.html.erb](i-rock/app/views/layouts/application.html.erb), add bootstrap nav markup and link to achievement view:

```ruby
<li class="nav-item">
  <%= link_to 'New Achievement', new_achievement_path %>
</li>
```

Modify [routes.rb](i-rock/config/routes.rb) to define achievement resource:

```ruby
Rails.application.routes.draw do
  resources :achievements, only: %i[new create]
  root to: 'welcome#index'
end
```

Add [achievements_controller.rb](i-rock/app/controllers/achievements_controller.rb)

```ruby
class AchievementsController < ApplicationController
  def new
  end
end
```

Add [achievements template](i-rock/app/views/achievements/new.html.erb) with simple form (will also need corresponding model):

```rails
<%= form_for @achievement do |f| %>
<% end %>
```

Go back to [achievements_controller.rb](i-rock/app/controllers/achievements_controller.rb) and define achievement model:

```ruby
class AchievementsController < ApplicationController
  def new
    @achievement = Achievement.new
  end
end
```

Generate model:

`privacy` property is integer because will be enum in model. Properties that don't have type specified are string.

```shell
$ bin/rails g model achievement title description:text privacy:integer featured:boolean cover_image
Running via Spring preloader in process 22053
  invoke  active_record
  create    db/migrate/20191117202131_create_achievements.rb
  create    app/models/achievement.rb
  invoke    rspec
  create      spec/models/achievement_spec.rb
  invoke      factory_bot
  create        spec/factories/achievements.rb
```

Run migration:

```shell
bin/rake db:migrate
```

Modify [achievements template](i-rock/app/views/achievements/new.html.erb) to use `simple_form`:

```ruby
<%= simple_form_for @achievement do |f| %>
<% end %>
```

Add `simple_form` to [Gemfile](i-rock/Gemfile), then install it and restart server:

```shell
$ bundle _1.17.3_
$ bin/rails g simple_form:install --bootstrap
Running via Spring preloader in process 23196
      create  config/initializers/simple_form.rb
      create  config/initializers/simple_form_bootstrap.rb
       exist  config/locales
      create  config/locales/simple_form.en.yml
      create  lib/templates/erb/scaffold/_form.html.erb
===============================================================================

  Be sure to have a copy of the Bootstrap stylesheet available on your
  application, you can get it on http://getbootstrap.com/.

  Inside your views, use the 'simple_form_for' with the Bootstrap form
  class, '.form-inline', as the following:

    = simple_form_for(@user, html: { class: 'form-inline' }) do |form|

===============================================================================
$ bin/rails s
```

Now go back to [achievements template](i-rock/app/views/achievements/new.html.erb) and define the form:

Now running tests `$ bin/rspec`, gets past filling in Title and fails on next field Description, add it to the template:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
<% end %>
```

Now tests fail because there is no Privacy selection, add this to template, specified `privacies` enum, which will have to define in the model:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :privacy, collection: Achievement.privacies %>
<% end %>
```

Add enum for privacy options to [achievement model](i-rock/app/models/achievement.rb)

```ruby
class Achievement < ActiveRecord::Base
  enum privacy: %i[public_access private_access friends_acceess]
end
```

Now test fails on unable to find option `Public`, because the options as defined in enum are lower case and underscored. Solution is to map them in template:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :privacy, collection: Hash[Achievement.privacies.map { |k,v| [k.split('_').first.capitalize, k]}] %>
<% end %>
```

Now test fails on unable to find checkbox. Add it, note that simple form knows `featured` is a boolean so automatically renders as checkbox:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :privacy, collection: Hash[Achievement.privacies.map { |k,v| [k.split('_').first.capitalize, k]}] %>
  <%= f.input :featured, label: 'Featured achievement' %>
<% end %>
```

Now tests fail on unable to upload file. Create `fixtures` dir in spec and copy some placeholder image there:

```shel
$ mkdir spec/fixtures
```

Modify template to create upload input:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :privacy, collection: Hash[Achievement.privacies.map { |k,v| [k.split('_').first.capitalize, k]}] %>
  <%= f.input :featured, label: 'Featured achievement' %>
  <%= f.input :cover_image, as: :file %>
<% end %>
```

Now test fails looking for `Create Achievement` button, add it to template:

```ruby
<%= simple_form_for @achievement do |f| %>
  <%= f.input :title %>
  <%= f.input :description %>
  <%= f.input :privacy, collection: Hash[Achievement.privacies.map { |k,v| [k.split('_').first.capitalize, k]}] %>
  <%= f.input :featured, label: 'Featured achievement' %>
  <%= f.input :cover_image, as: :file %>
  <%= f.submit 'Create Achievement', class: 'btn btn-primary' %>
<% end %>
```

Now test fails on `The action 'create' could not be found for AchievementsController`. Define this in [controller](i-rock/app/controllers/achievements_controller.rb):

```ruby
class AchievementsController < ApplicationController
  def new
    @achievement = Achievement.new
  end

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      redirect_to root_url, notice: 'Achievement has been created'
    end
  end

  private

  def achievement_params
    params.require(:achievement).permit(:title, :description, :privacy, :cover_image, :featured)
  end
end
```

But test still failing on not finding success message because app is not currently setup to display flash messages. Fix this in [application layout](i-rock/app/views/layouts/application.html.erb):

```ruby
<% if flash[:notice] %>
  <div class="alert alert-info"><%= flash[:notice] %></div>
<% end %>
<%= yield %>
```

FINALLY, now spec is passing!

Verify in rails console:

```shell
$ bin/rails c
irb(main):001:0> Achievement.last
  Achievement Load (0.2ms)  SELECT  "achievements".* FROM "achievements"  ORDER BY "achievements"."id" DESC LIMIT 1
=> #<Achievement id: 3, title: "my first achievement", description: "some description blah blah", privacy: 0, featured: true, cover_image: "
#<ActionDispatch::Http::UploadedFile:0x007fa0255ce...", created_at: "2019-11-17 22:04:22", updated_at: "2019-11-17 22:04:22">
```

### First Feature Spec: Sad Path

When things go wrong...

Add another scenario to [test](i-rock/spec/features/create_achievement_spec.rb) that attempts to submit empty form and expects error message.

```ruby
scenario 'cannot create achievement with invalid data' do
  visit('/')
  click_on('New Achievement')
  click_on('Create Achievement')

  expect(page).to have_content("can't be blank")
end
```

This will fail because currently there is no validation so all empty form values are allowed.

To fix this, add validation to [achievement model](i-rock/app/models/achievement.rb):

```ruby
class Achievement < ActiveRecord::Base
  validates :title, presence: true
  enum privacy: %i[public_access private_access friends_acceess]
end
```

But now running tests get `ActionView: MissingTemplate`. This is because in [controller create method](i-rock/app/controllers/achievements_controller.rb), only handling the success case. Solution:

```ruby
def create
  @achievement = Achievement.new(achievement_params)
  if @achievement.save
    redirect_to root_url, notice: 'Achievement has been created'
  else
    render :new
  end
end
```

Now test is passing.

What about validating all other fields such as Description, etc? Could add more scenarios to acceptance test but this is a high cost/low value way of testing validations. Recommend to just have one error case at acceptance level, then create more unit tests at model level to verify each individual field validation (covered later in this course).

### Page Object Pattern