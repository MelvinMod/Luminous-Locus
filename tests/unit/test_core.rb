# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/resurgence_engine'

module ResurgenceEngine
  # Unit tests for core types
  class TestTypes < Minitest::Test
    def test_uint32_valid
      assert Types.uint32?(0)
      assert Types.uint32?(2_147_483_647)
      assert Types.uint32?(4_294_967_295)
      refute Types.uint32?(-1)
      refute Types.uint32?(4_294_967_296)
    end

    def test_int32_valid
      assert Types.int32?(-2_147_483_648)
      assert Types.int32?(0)
      assert Types.int32?(2_147_483_647)
      refute Types.int32?(-2_147_483_649)
      refute Types.int32?(2_147_483_648)
    end
  end

  # Unit tests for Position
  class TestPosition < Minitest::Test
    def test_position_creation
      pos = Position[5, 10, 2]
      assert_equal 5, pos.x
      assert_equal 10, pos.y
      assert_equal 2, pos.z
    end

    def test_position_default_z
      pos = Position[5, 10]
      assert_equal 0, pos.z
    end

    def test_position_neighbor
      pos = Position[5, 5, 0]
      assert_equal Position[4, 5, 0], pos.neighbor(Direction::WEST)
      assert_equal Position[6, 5, 0], pos.neighbor(Direction::EAST)
      assert_equal Position[5, 4, 0], pos.neighbor(Direction::NORTH)
      assert_equal Position[5, 6, 0], pos.neighbor(Direction::SOUTH)
      assert_equal Position[5, 5, 1], pos.neighbor(Direction::UP)
      assert_equal Position[5, 5, -1], pos.neighbor(Direction::DOWN)
    end

    def test_position_within_bounds
      pos = Position[5, 5, 0]
      assert pos.within?(10, 10, 1)
      refute pos.within?(5, 5, 1)
      refute pos.within?(3, 10, 1)
    end

    def test_manhattan_distance
      pos1 = Position[0, 0, 0]
      pos2 = Position[3, 4, 0]
      assert_equal 7, pos1.manhattan_distance(pos2)
    end

    def test_position_equality
      pos1 = Position[1, 2, 3]
      pos2 = Position[1, 2, 3]
      assert_equal pos1, pos2
      refute_equal pos1, Position[1, 2, 4]
    end

    def test_position_to_a
      pos = Position[1, 2, 3]
      assert_equal [1, 2, 3], pos.to_a
    end
  end

  # Unit tests for Direction
  class TestDirection < Minitest::Test
    def test_direction_names
      assert_equal 'NORTH', Direction.name(Direction::NORTH)
      assert_equal 'SOUTH', Direction.name(Direction::SOUTH)
      assert_equal 'EAST', Direction.name(Direction::EAST)
      assert_equal 'WEST', Direction.name(Direction::WEST)
    end

    def test_opposite_direction
      assert_equal Direction::SOUTH, Direction.opposite(Direction::NORTH)
      assert_equal Direction::NORTH, Direction.opposite(Direction::SOUTH)
      assert_equal Direction::WEST, Direction.opposite(Direction::EAST)
      assert_equal Direction::EAST, Direction.opposite(Direction::WEST)
    end

    def test_diagonal_detection
      assert Direction.diagonal?(Direction::NORTHEAST)
      assert Direction.diagonal?(Direction::SOUTHWEST)
      refute Direction.diagonal?(Direction::NORTH)
      refute Direction.diagonal?(Direction::SOUTH)
    end

    def test_from_string
      assert_equal Direction::NORTH, Direction.from_string('north')
      assert_equal Direction::SOUTH, Direction.from_string('SOUTH')
      assert_equal Direction::EAST, Direction.from_string('East')
    end
  end

  # Unit tests for IdPtr
  class TestIdPtr < Minitest::Test
    def setup
      IdPtr.reset!
    end

    def test_id_generation
      id1 = IdPtr.generate(Object)
      id2 = IdPtr.generate(Object)
      refute_equal id1.id, id2.id
    end

    def test_id_validity
      id = IdPtr.generate(Object)
      assert id.valid?
      assert IdPtr.invalid.invalid?
    end

    def test_id_equality
      id1 = IdPtr.new(id: 1, type: Object)
      id2 = IdPtr.new(id: 1, type: Object)
      assert_equal id1, id2
    end
  end

  # Unit tests for Object
  class TestObject < Minitest::Test
    def setup
      @obj = Object.new(name: 'Test')
    end

    def test_object_creation
      assert_equal 'Test', @obj.name
      assert @obj.id.valid?
      assert @obj.initialized
    end

    def test_tags
      @obj.add_tag(:solid)
      @obj.add_tag(:passable, false)

      assert @obj.tagged?(:solid)
      refute @obj.tagged?(:destroyed)
      assert_equal false, @obj.get_tag(:passable)
      assert_nil @obj.get_tag(:nonexistent)
    end

    def test_remove_tag
      @obj.add_tag(:test)
      assert @obj.tagged?(:test)

      @obj.remove_tag(:test)
      refute @obj.tagged?(:test)
    end

    def test_health
      @obj.set_health(75, 100)
      assert_equal 75, @obj.health
      assert_equal 100, @obj.max_health
      assert_equal 0.75, @obj.health_percentage

      @obj.modify_health(-10)
      assert_equal 65, @obj.health
    end

    def test_delete
      @obj.delete
      assert @obj.deleted
    end

    def test_serialization
      data = @obj.serialize
      assert_equal 'Test', data['name']
      assert_equal @obj.id.id, data['id']
    end
  end

  # Unit tests for Map
  class TestMap < Minitest::Test
    def setup
      @map = Map.new(width: 10, height: 10, depth: 1, name: 'test_map')
    end

    def test_map_creation
      assert_equal 10, @map.width
      assert_equal 10, @map.height
      assert_equal 1, @map.depth
      assert_equal 'test_map', @map.name
    end

    def test_valid_position
      assert @map.valid_position?(Position[0, 0, 0])
      assert @map.valid_position?(Position[9, 9, 0])
      refute @map.valid_position?(Position[10, 0, 0])
      refute @map.valid_position?(Position[-1, 0, 0])
    end

    def test_set_and_get_cell
      obj = Object.new
      @map.set_cell(Position[5, 5, 0], obj)

      assert_equal obj, @map.get_cell(Position[5, 5, 0])
    end

    def test_occupied
      obj = Object.new
      @map.set_cell(Position[3, 3, 0], obj)

      assert @map.occupied?(Position[3, 3, 0])
      refute @map.occupied?(Position[4, 4, 0])
    end

    def test_neighbors
      pos = Position[5, 5, 0]
      neighbors = @map.get_neighbors(pos, Direction::CARDINAL)

      assert_equal 4, neighbors.size
      assert neighbors.key?(Direction::NORTH)
      assert neighbors.key?(Direction::SOUTH)
      assert neighbors.key?(Direction::EAST)
      assert neighbors.key?(Direction::WEST)
    end

    def test_find_all
      obj1 = Object.new
      obj2 = Object.new
      @map.set_cell(Position[2, 2, 0], obj1)
      @map.set_cell(Position[8, 8, 0], obj2)

      found = @map.find_all { |pos, obj| !obj.nil? }
      assert_equal 2, found.size
    end

    def test_random_position
      pos = @map.random_position
      assert pos
      assert @map.valid_position?(pos)
    end
  end

  # Unit tests for World
  class TestWorld < Minitest::Test
    def setup
      @world = World.new
    end

    def test_world_creation
      assert_empty @world.maps
      assert_equal 0.0, @world.time
      refute @world.running
    end

    def test_add_map
      map = Map.new(name: 'test', width: 50, height: 50)
      @world.add_map(map)

      assert @world.map_exists?('test')
      assert_equal map, @world.get_map('test')
      assert_equal map, @world.active_map
    end

    def test_remove_map
      map = Map.new(name: 'test', width: 50, height: 50)
      @world.add_map(map)
      @world.remove_map('test')

      refute @world.map_exists?('test')
    end

    def test_start_stop
      @world.start
      assert @world.running

      @world.stop
      refute @world.running
    end
  end
end