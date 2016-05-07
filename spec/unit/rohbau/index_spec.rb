require 'spec_helper'
require 'rohbau/index'
require 'rohbau/entity'

describe Rohbau::Index do
  let(:index) { Rohbau::Index.new }
  let(:entity) { Entity.new }

  describe 'default options' do
    it 'enables uid_generation' do
      assert index.option?(:uid_generation)
    end

    it 'assigns DefaultMapper as mapper' do
      assert index.option?(:mapper)
      assert_equal Rohbau::Index::DefaultMapper, index.option(:mapper)
    end

    it 'assigns DefaultMapper as unmapper' do
      assert index.option?(:unmapper)
      assert_equal Rohbau::Index::DefaultMapper, index.option(:unmapper)
    end
  end

  describe 'setting options' do
    it 'disables uid_generation' do
      index.option(:uid_generation, false)

      refute index.option?(:uid_generation)
    end

    it 'assigns OwnMapper as mapper' do
      index.option(:mapper, OwnMapper)

      assert_equal OwnMapper, index.option(:mapper)
    end

    it 'assigns OwnMapper as unmapper' do
      index.option(:unmapper, OwnMapper)

      assert_equal OwnMapper, index.option(:unmapper)
    end
  end

  describe 'size' do
    describe 'empty' do
      it 'has size 0' do
        assert_equal 0, index.size
      end
    end

    describe 'with entities' do
      before do
        index.add(entity)
      end

      it 'has size 1' do
        assert_equal 1, index.size
      end
    end
  end

  describe 'each' do
    describe 'empty' do
      it 'yields nothing' do
        a = 0
        index.each do
          a += 1
        end

        assert_equal 0, a
      end
    end

    describe 'with entities' do
      before do
        index.add(entity)
      end

      it 'yields block for every entity' do
        a = 0
        index.each do
          a += 1
        end

        assert_equal 1, a
      end
    end
  end

  describe 'all' do
    describe 'empty' do
      it 'does not contain any entities' do
        assert_equal [], index.all
      end
    end

    describe 'with entities' do
      it 'returns all entities' do
        added_entity = index.add(entity)

        assert_equal [added_entity], index.all
      end
    end
  end

  describe 'add' do
    describe 'without uid' do
      it 'generates a uid' do
        refute entity.uid

        added_entity = index.add(entity)

        assert_equal '1', added_entity.uid
      end

      it 'is present in collection' do
        added_entity = index.add(entity)

        assert_equal added_entity, index.all[0]
      end
    end

    describe 'with uid' do
      it 'should fail' do
        entity.uid = '1'

        error = assert_raises(ArgumentError) do
          index.add(entity)
        end

        assert_match Regexp.new('entity has uid'), error.message
      end
    end

    describe 'without entity' do
      it 'should fail' do
        error = assert_raises(ArgumentError) do
          index.add(nil)
        end

        assert_match Regexp.new('entity is invalid'), error.message
      end
    end

    describe 'without uid_generation' do
      let(:uid) { '1' }

      before do
        index.option(:uid_generation, false)
      end

      describe 'with uid' do
        before do
          entity.uid = uid
        end

        it 'keeps the uid' do
          added_entity = index.add(entity)

          assert_equal uid, added_entity.uid
        end

        it 'is present in collection' do
          added_entity = index.add(entity)

          assert_equal added_entity, index.all[0]
        end
      end

      describe 'without uid' do
        it 'should fail' do
          error = assert_raises(ArgumentError) do
            index.add(entity)
          end

          assert_match Regexp.new('entity has no uid'), error.message
        end
      end

      describe 'with invalid uid' do
        it 'should fail' do
          ['', 1].each do |invalid_uid|
            entity.uid = invalid_uid

            error = assert_raises(ArgumentError) do
              index.add(entity)
            end

            assert_match Regexp.new('uid is invalid'), error.message
          end
        end
      end
    end

    describe 'bulk_add' do
      let(:entities) { [entity, entity] }

      it 'adds multiple entities' do
        added_entities = index.bulk_add(entities)

        assert_equal added_entities, index.all
      end
    end

    describe 'get' do
      let(:entities) { [entity, entity] }

      it 'gets entity by uid' do
        added_entity = index.add(entity)

        assert_equal added_entity, index.get(added_entity.uid)
      end

      describe 'without uid' do
        it 'should fail' do
          error = assert_raises(ArgumentError) do
            index.get(nil)
          end

          assert_match Regexp.new('uid is missing'), error.message
        end
      end

      describe 'with invalid uid' do
        it 'should fail' do
          ['', 1].each do |invalid_uid|
            entity.uid = invalid_uid

            error = assert_raises(ArgumentError) do
              index.get(entity.uid)
            end

            assert_match Regexp.new('uid is invalid'), error.message
          end
        end
      end
    end

    describe 'update' do
      it 'succeeds' do
        added_entity = index.add(entity)

        refute added_entity.name

        added_entity.name = 'foo'
        updated_entity = index.update(added_entity)

        assert_equal 'foo', updated_entity.name
      end

      describe 'without uid' do
        it 'should fail' do
          error = assert_raises(ArgumentError) do
            index.update(entity)
          end

          assert_match Regexp.new('entity has no uid'), error.message
        end
      end

      describe 'without entity' do
        it 'should fail' do
          error = assert_raises(ArgumentError) do
            index.update(nil)
          end

          assert_match Regexp.new('entity is invalid'), error.message
        end
      end

      describe 'with unknown entity' do
        it 'should fail' do
          entity.uid = 'unknown'

          error = assert_raises(ArgumentError) do
            index.update(entity)
          end

          assert_match Regexp.new('entity is unknown'), error.message
        end
      end
    end

    describe 'delete' do
      it 'removes entity' do
        added_entity = index.add(entity)

        assert index.get(added_entity.uid)
        index.delete(added_entity.uid)

        refute index.get(added_entity.uid)
      end

      describe 'with unknown uid' do
        it 'should fail' do
          uid = 'unknown'

          error = assert_raises(ArgumentError) do
            index.delete(uid)
          end

          assert_match Regexp.new('uid is unknown'), error.message
        end
      end
    end

    describe 'bulk_delete' do
      let(:entities) { [entity, entity] }

      it 'removes multiple entities' do
        added_entities = index.bulk_add(entities)

        assert_equal added_entities, index.all

        index.bulk_delete(added_entities.map(&:uid))

        assert_equal [], index.all
      end
    end

    describe 'has_uid?' do
      it 'fails with unknown uid' do
        refute index.has_uid?('unknown')
      end

      it 'succeeds with known uid' do
        added_entity = index.add(entity)

        assert index.has_uid?(added_entity.uid)
      end
    end
  end

  private

  class Entity < Rohbau::Entity
    attributes :uid, :name
  end

  class OwnMapper
  end
end
