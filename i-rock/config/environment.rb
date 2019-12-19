# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# https://stackoverflow.com/questions/25712027/nameerror-uninitialized-constant-articleimageuploader-when-using-carrierwave
require 'carrierwave/orm/activerecord'
