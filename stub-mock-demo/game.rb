# frozen_string_literal: true

# The Character class
class Character
  def initialize(strength: 1, die: Die.new, logger: Logger.new)
    @strength = strength
    @die = die
    @logger = logger
  end

  def climb(difficulty: 10)
    roll = die.roll + strength
    logger.log("Climbing check. Difficulty: #{difficulty}. Roll: #{roll}")
    roll >= difficulty
  end

  private

  attr_reader :die, :strength, :logger
end

describe Character do
  describe 'climbing check skill' do
    # Stub dependencies of Character class using test doubles
    let(:die) { double }
    # Parameters to double: Class, and method and what it returns
    let(:logger) { double('Logger', log: nil) }

    # Instantiate object under test, passing in test doubles via dependency injection
    let(:character) { Character.new(strength: 5, die: die, logger: logger) }

    it 'climbs successfully when roll + strength is more than difficulty' do
      # Stub the roll method
      allow(die).to receive(:roll) { 11 }
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    it 'fails successfully when roll + strength is less than difficulty' do
      allow(die).to receive(:roll) { 5 }
      expect(character.climb(difficulty: 15)).to be_falsy
    end

    it 'commands logger to log climb skill check' do
      # Arrange: stub roll method
      allow(die).to receive(:roll) { 7 }
      # Assert: before act when using mocks
      expect(logger).to receive(:log).with('Climbing check. Difficulty: 10. Roll: 12')
      # Act: invoke method under test
      character.climb(difficulty: 10)
    end
  end
end
