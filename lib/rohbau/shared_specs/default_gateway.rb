module Rohbau
  module SharedSpecs
    DefaultGateway = Proc.new do
      describe 'add' do
        it 'inserts an entity' do
          subject.add entity
          assert_equal 1, subject.size
        end

        it 'returns a copied entity' do
          new_entity = subject.add entity
          refute_equal new_entity.object_id, entity.object_id
        end

        it 'assigns a string uid to the entity' do
          new_entity = subject.add entity
          refute_nil new_entity.uid
          assert_kind_of String, new_entity.uid
        end

        it 'raises an error if entity is nil' do
          assert_raises ArgumentError do
            subject.add nil
          end
        end

        it 'raises an error if entity has already an uid' do
          entity.uid = '45'
          assert_raises ArgumentError do
            subject.add entity
          end
        end
      end

      describe 'bulk_add' do
        it 'inserts a collection of entities' do
          entities = [entity, updated_entity]

          subject.bulk_add entities
          assert_equal 2, subject.size
        end

        it 'returns a collection copied entities' do
          entities = [entity]

          new_entities = subject.bulk_add entities
          refute_equal new_entities[0].object_id, entities[0].object_id
        end

        it 'assigns a string uid to the entities' do
          entities = [entity]

          new_entities = subject.bulk_add entities
          refute_nil new_entities[0].uid
          assert_kind_of String, new_entities[0].uid
        end

        it 'raises an error if entities are nil' do
          assert_raises ArgumentError do
            subject.bulk_add [nil]
          end
        end

        it 'raises an error if entity has already an uid' do
          entity.uid = '45'
          assert_raises ArgumentError do
            subject.bulk_add [entity]
          end
        end
      end

      describe 'all' do
        it 'returns an empty array' do
          assert_equal [], subject.all
        end

        it 'returns added entities' do
          entities = [entity, updated_entity].map do |e|
            subject.add e
          end

          assert_equal entities, subject.all
        end
      end

      describe 'get' do
        it 'returns nothing if uid not found' do
          assert_equal nil, subject.get('23')
        end

        it 'raises an error if uid is an invalid value' do
          ["", nil, 22].each do |value|
            assert_raises ArgumentError do
              subject.get(value)
            end
          end
        end

        it 'returns the entity for a known uid' do
          entities = [entity, updated_entity].map do |e|
            subject.add e
          end

          assert_equal entities.first,  subject.get(entities.first.uid)
          assert_equal entities.last,   subject.get(entities.last.uid)
        end
      end

      describe 'entity duplication' do
        it 'returns a copy of the stored entity on get' do
          uid = subject.add(entity).uid

          e = subject.get(uid)
          e.uid = uid + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'returns a copy of the stored entity on add' do
          result = subject.add(entity)
          uid = result.uid

          result.uid = uid + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'adds a copy as stored entity on add' do
          uid = subject.add(entity).uid

          entity.uid = uid  + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'returns copies of the stored entities on all' do
          uid = subject.add(entity).uid

          e = subject.all.first
          e.uid = uid + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'returns a copy of the stored entity on update' do
          stored = subject.add(entity)
          uid = stored.uid

          result = subject.update(stored)

          result.uid = uid + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'returns copies of the stored entities on bulk_add' do
          entities = [entity]

          results = subject.bulk_add(entities)
          uid = results[0].uid

          results[0].uid = uid + '1'

          assert_equal uid, subject.get(uid).uid
        end

        it 'adds copies as stored entities on bulk_add' do
          entities = [entity]

          results = subject.bulk_add(entities)
          uid = results[0].uid

          entity.uid = uid  + '1'

          assert_equal uid, subject.get(uid).uid
        end
      end

      describe 'update' do
        it 'fails if nil is given' do
          assert_raises ArgumentError do
            subject.update(nil)
          end
        end

        it 'fails if uid is nil' do
          assert_raises ArgumentError do
            entity.uid = nil
            subject.update(entity)
          end
        end

        it 'fails if uid is not known' do
          assert_raises ArgumentError do
            entity.uid = "22"
            subject.update(entity)
          end
        end

        it 'updates and returns the entity' do
          added_entity = subject.add(entity)
          uid = added_entity.uid

          updated_entity.uid = uid
          result = subject.update(updated_entity)

          assert_equal subject.get(uid),  result
          refute_equal added_entity,      result
        end
      end

      describe 'delete' do
        it 'fails if nil is given' do
          assert_raises ArgumentError do
            subject.delete(nil)
          end
        end

        it 'fails if uid is not known' do
          assert_raises ArgumentError do
            subject.delete('22')
          end
        end

        it 'deletes the entity' do
          uid = subject.add(entity).uid

          assert subject.get(uid)

          subject.delete(uid)

          refute subject.get(uid)
        end

        it 'returns deleted entity' do
          uid = subject.add(entity).uid

          persisted_entity = subject.get(uid)

          assert_equal persisted_entity, subject.delete(uid)
        end

        it 'removes the entity from the collection' do
          uid = subject.add(entity).uid
          subject.add(updated_entity)

          subject.delete(uid)

          assert_equal 1, subject.all.size
          refute_includes subject.all.map(&:uid), uid
        end
      end

      describe 'bulk_delete' do
        it 'raises an error if nil is given' do
          assert_raises ArgumentError do
            subject.bulk_delete([nil])
          end
        end

        it 'raises an error if uid is not known' do
          assert_raises ArgumentError do
            subject.bulk_delete(['22'])
          end
        end

        it 'deletes the entities' do
          uid  = subject.add(entity).uid
          uids = [uid]

          assert subject.get(uid)

          subject.bulk_delete(uids)

          refute subject.get(uid)
        end

        it 'returns deleted entity' do
          uid = subject.add(entity).uid
          uids = [uid]

          persisted_entity = subject.get(uid)

          assert_equal persisted_entity, subject.bulk_delete(uids)[0]
        end

        it 'removes the entity from the collection' do
          uid = subject.add(entity).uid
          uids = [uid]

          subject.add(updated_entity).uid

          subject.bulk_delete(uids)

          assert_equal 1, subject.all.size
          refute_includes subject.all.map(&:uid), uid
        end
      end
    end
  end
end
