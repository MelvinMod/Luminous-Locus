# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/resurgence_engine'

module ResurgenceEngine
  # Unit tests for MapObject classes
  class TestMapObject < Minitest::Test
    def setup
      @map = Map.new(width: 20, height: 20, depth: 2, name: 'test')
      @obj = MapObject.new(
        name: 'TestObj',
        position: Position[5, 5, 0]
      )
    end

    def test_map_object_creation
      assert_equal 'TestObj', @obj.name
      assert_equal Position[5, 5, 0], @obj.position
      assert @obj.visible
    end

    def test_move_to
      @map.set_cell(Position[5, 5, 0], @obj)

      success = @obj.move_to(Position[6, 6, 0])
      assert success
      assert_equal Position[6, 6, 0], @obj.position
    end

    def test_move_blocked
      @map.set_cell(Position[5, 5, 0], @obj)
      blocker = Object.new
      @map.set_cell(Position[6, 6, 0], blocker)

      success = @obj.move_to(Position[6, 6, 0])
      refute success
    end

    def test_get_view_info
      @obj.instance_variable_set(:@icon_path, 'test_icon')
      @obj.instance_variable_set(:@icon_state, 'test_state')

      view = @obj.get_view_info
      assert_equal 'test_icon', view.icon
      assert_equal 'test_state', view.icon_state
    end
  end

  # Unit tests for Turf
  class TestTurf < Minitest::Test
    def test_turf_creation
      turf = Turf.new(
        name: 'Floor',
        category: 'floor',
        solid: false,
        walkable: true
      )

      assert turf.tagged?(:turf)
      assert turf.tagged?(:floor)
      assert turf.diggable?
    end

    def test_turf_damage
      turf = Turf.new(turf_health: 100)

      turf.damage_turf(30)
      assert_equal 70, turf.turf_health
      assert turf.damaged?
    end

    def test_turf_destroyed
      turf = Turf.new

      turf.damage_turf(150)
      assert turf.tagged?(:destroyed)
      assert turf.excavated
    end

    def test_sealed_turf_not_diggable
      turf = Turf.new(sealed: true)

      refute turf.diggable?
      turf.damage_turf(200)
      assert_equal 100, turf.turf_health  # No damage
    end
  end

  # Unit tests for Structure
  class TestStructure < Minitest::Test
    def test_structure_creation
      struct = Structure.new(
        name: 'Wall',
        opaque: true,
        structure_health: 200,
        max_structure_health: 200
      )

      assert struct.tagged?(:structure)
      assert struct.blocks_movement?
      assert struct.blocks_los?
    end

    def test_structure_damage
      struct = Structure.new(structure_health: 100)

      struct.damage(30)
      assert_equal 70, struct.structure_health
      assert struct.damaged?
    end

    def test_structure_destroyed
      struct = Structure.new

      struct.damage(150)
      assert struct.destroyed?
      refute struct.blocks_movement?
      refute struct.blocks_los?
    end

    def test_structure_repair
      struct = Structure.new(structure_health: 50, max_structure_health: 100)

      struct.repair(30)
      assert_equal 80, struct.structure_health
    end

    def test_structure_open_close
      struct = Structure.new(open: false)

      assert struct.blocks_movement?

      struct.toggle_open
      assert struct.open
      refute struct.blocks_movement?
    end
  end

  # Unit tests for Item
  class TestItem < Minitest::Test
    def test_item_creation
      item = Item.new(
        name: 'Sword',
        weight: 500,
        volume: 100,
        category: 'weapon'
      )

      assert item.tagged?(:item)
      assert item.tagged?(:weapon)
      assert_equal 500, item.weight
    end

    def test_item_container
      container = Item.new(
        name: 'Box',
        is_container: true,
        volume: 1000
      )

      item = Item.new(name: 'Rock', weight: 200)

      assert container.add_item(item)
      assert container.contents.include?(item)
      assert_equal 200, container.total_weight
    end

    def test_item_condition
      item = Item.new(condition: 100, max_condition: 100)

      item.damage(30)
      assert_equal 70, item.condition
      assert item.broken? if item.condition <= 0
    end
  end

  # Unit tests for Movable
  class TestMovable < Minitest::Test
    def setup
      @map = Map.new(width: 20, height: 20, depth: 1)
      @movable = Movable.new(
        name: 'TestMovable',
        position: Position[10, 10, 0],
        speed: 4
      )
      @map.set_cell(Position[10, 10, 0], @movable)
    end

    def test_movement
      @movable.move(Direction::EAST)
      assert_equal 11, @movable.position.x
    end

    def test_movement_lock
      @movable.lock_movement
      @movable.move(Direction::EAST)
      assert_equal 10, @movable.position.x  # Didn't move

      @movable.unlock_movement
      @movable.move(Direction::EAST)
      assert_equal 11, @movable.position.x  # Now can move
    end

    def test_destination
      @movable.set_destination(Position[15, 15, 0])
      assert @movable.moving
      assert @movable.destination
    end

    def test_stop_moving
      @movable.set_destination(Position[15, 15, 0])
      @movable.stop_moving

      refute @movable.moving
      assert_nil @movable.destination
    end
  end

  # Unit tests for Mob
  class TestMob < Minitest::Test
    def setup
      @mob = Mob.new(
        name: 'TestMob',
        position: Position[5, 5, 0],
        health: 100,
        max_health: 100
      )
      @mob.create_inventory
    end

    def test_mob_creation
      assert @mob.tagged?(:mob)
      assert_equal 100, @mob.health
      assert @mob.alive?
    end

    def test_mob_take_damage
      @mob.take_damage(30, :brute)
      assert_equal 30, @mob.brute_damage
      assert_equal 70, @mob.health

      @mob.take_damage(80, :brute)
      assert @mob.dead?
    end

    def test_mob_heal
      @mob.take_damage(40, :brute)
      assert_equal 60, @mob.health

      @mob.heal(20, :brute)
      assert_equal 20, @mob.brute_damage
      assert_equal 80, @mob.health
    end

    def test_mob_status_flags
      refute @mob.status_flag?(StatusFlags::SLEEPING)

      @mob.set_status(StatusFlags::SLEEPING)
      assert @mob.status_flag?(StatusFlags::SLEEPING)

      @mob.clear_status(StatusFlags::SLEEPING)
      refute @mob.status_flag?(StatusFlags::SLEEPING)
    end

    def test_mob_mutations
      @mob.add_mutation(:night_vision)
      assert @mob.has_mutation?(:night_vision)

      @mob.remove_mutation(:night_vision)
      refute @mob.has_mutation?(:night_vision)
    end

    def test_mob_inventory
      item = Item.new(name: 'Sword')
      assert @mob.inventory.add(item)

      assert @mob.inventory.contains?(item)
      assert @mob.inventory.find_by_tag(:item).include?(item)
    end

    def test_mob_equipment
      armor = Item.new(
        name: 'Armor',
        equippable: true,
        equip_slot: :chest
      )
      @mob.inventory.add(armor)
      @mob.equip_item(armor, :chest)

      assert_equal armor, @mob.get_equipped(:chest)
      assert armor.equipped?
    end
  end

  # Unit tests for Inventory
  class TestInventory < Minitest::Test
    def setup
      @inv = Inventory.new(max_slots: 5, max_weight: 1000, max_volume: 1000)
    end

    def test_inventory_creation
      assert_equal 5, @inv.max_slots
      assert_equal 0, @inv.current_weight
      assert_equal 0, @inv.current_volume
    end

    def test_add_items
      item1 = Item.new(name: 'Item1', weight: 100, volume: 100)
      item2 = Item.new(name: 'Item2', weight: 200, volume: 150)

      assert @inv.add(item1)
      assert @inv.add(item2)

      assert_equal 2, @inv.items.compact.size
      assert_equal 300, @inv.current_weight
      assert_equal 250, @inv.current_volume
    end

    def test_remove_items
      item = Item.new(name: 'Item', weight: 100, volume: 100)
      @inv.add(item)
      @inv.remove(item)

      assert_nil @inv[0]
      assert_equal 0, @inv.current_weight
    end

    def test_inventory_full
      5.times do |i|
        item = Item.new(name: "Item#{i}", weight: 100, volume: 100)
        @inv.add(item)
      end

      assert @inv.full?
      assert_equal 0, @inv.empty_slots

      extra = Item.new(name: 'Extra', weight: 50, volume: 50)
      refute @inv.add(extra)
    end

    def test_overweight
      item = Item.new(name: 'Heavy', weight: 1500, volume: 100)
      refute @inv.add(item)
    end

    def test_find_by_category
      sword = Item.new(name: 'Sword', category: 'weapon')
      shield = Item.new(name: 'Shield', category: 'weapon')
      apple = Item.new(name: 'Apple', category: 'food')

      @inv.add(sword)
      @inv.add(shield)
      @inv.add(apple)

      weapons = @inv.find_by_category('weapon')
      assert_equal 2, weapons.size
      assert_includes weapons, sword
      refute_includes weapons, apple
    end
  end
end