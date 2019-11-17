# frozen_string_literal: true

# Class to demonstrate basic rspec
class Playground
  def initialize(children)
    @children = children
  end

  def empty?
    @children.zero?
  end

  def mood
    'boring'
  end
end
