require 'spec_helper'
require 'rohbau/entity'

describe Rohbau::Entity do
  describe 'class' do
    let(:entity_class) { Rohbau::Entity }

    it 'accepts list of attributes' do
      entity_class.attributes(:city, :country)
    end

    it 'initializes' do
      assert entity_class.new.is_a?(Rohbau::Entity)
    end
  end

  describe 'instance' do
    let(:entity) { Person.new }

    it 'provides accessor' do
      assert_equal nil, entity.name

      entity.name = 'fasel'

      assert_equal 'fasel', entity.name
    end

    describe 'predicate attribute' do
      it 'should be false without value' do
        assert_equal false, entity.name?
      end

      it 'should be false with false as value' do
        entity.name = false

        assert_equal false, entity.name?
      end

      it 'should be true with value' do
        entity.name = 'fasel'

        assert_equal true, entity.name?
      end
    end

    describe 'equality' do
      let(:person_1) { Person.new }
      let(:person_2) { Person.new }
      let(:dog) { Dog.new }
      let(:cat) { Cat.new }

      it 'is equal with identical entity class' do
        [person_1, person_2].each do |entity|
          entity.name = 'Johnny'
        end

        assert person_1 == person_2
      end

      it 'is equal with different entity classes' do
        [person_1, dog].each do |entity|
          entity.name = 'Johnny'
        end

        assert person_1 == dog
      end

      it 'is equal with additional attribute' do
        [dog, cat].each do |entity|
          entity.name = 'Johnny'
        end

        assert dog == cat
      end

      it 'is not equal with missing attribute' do
        [dog, cat].each do |entity|
          entity.name = 'Johnny'
        end

        refute cat == dog
      end

      it 'is not equal with different attributes' do
        person_1.name = 'Johnny'
        person_2.name = 'Brad'

        refute person_1 == person_2
      end
    end
  end

  private

  class Person < Rohbau::Entity
    attributes :name, :name?
  end

  class Dog < Rohbau::Entity
    attributes :name, :name?
  end

  class Cat < Rohbau::Entity
    attributes :name, :name?, :color
  end
end
