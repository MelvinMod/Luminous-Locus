# frozen_string_literal: true

module ResurgenceEngine
  # Item class - pickupable objects
  #
  # Items can be picked up, dropped, and stored in inventories.
  class Item < Movable
    # @return [Integer] Item weight in grams
    attr_accessor :weight

    # @return [Integer] Item volume in mL
    attr_accessor :volume

    # @return [String] Item category
    attr_accessor :category

    # @return [Boolean] Whether the item is equippable
    attr_accessor :equippable

    # @return [Symbol, nil] Slot for equipment
    attr_accessor :equip_slot

    # @return [Boolean] Whether currently equipped
    attr_accessor :equipped

    # @return [Integer] Item condition (0-100)
    attr_accessor :condition

    # @return [Integer] Max condition
    attr_accessor :max_condition

    # @return [Boolean] Whether the item is a container
    attr_accessor :is_container

    # @return [Array<Item>] Contents if container
    attr_accessor :contents

    # Initialize a new item
    def initialize(
      weight: 100,
      volume: 100,
      category: 'misc',
      equippable: false,
      equip_slot: nil,
      equipped: false,
      condition: 100,
      max_condition: 100,
      is_container: false,
      **kwargs
    )
      super(**kwargs)
      @weight = weight
      @volume = volume
      @category = category
      @equippable = equippable
      @equip_slot = equip_slot
      @equipped = equipped
      @condition = condition
      @max_condition = max_condition
      @is_container = is_container
      @contents = []

      add_tag(:item)
      add_tag(category.to_sym) if category
    end

    # Get total weight including contents
    # @return [Integer]
    def total_weight
      base = @weight || 0
      @contents.sum(&:total_weight) + base
    end

    # Get total volume including contents
    # @return [Integer]
    def total_volume
      base = @volume || 0
      @contents.sum(&:total_volume) + base
    end

    # Pick up the item
    # @param mob [Mob] Mob picking up the item
    # @return [Boolean] Success
    def pickup(mob)
      return false unless mob&.inventory

      success = mob.inventory.add(self)
      if success
        remove_from_map
        on_pickup(mob)
      end
      success
    end

    # Drop the item
    # @param mob [Mob] Mob dropping the item
    # @param position [Position] Position to drop at
    # @return [Boolean] Success
    def drop(mob, position)
      return false unless position && mob.inventory.contains?(self)

      mob.inventory.remove(self)
      place_on_map(position)
      on_drop(mob, position)
    end

    # Equip the item
    # @param mob [Mob] Mob equipping the item
    # @return [Boolean] Success
    def equip(mob)
      return false unless @equippable
      return false unless mob.inventory.contains?(self)
      return false if @equipped

      success = mob.equip_item(self)
      @equipped = success
      on_equip(mob) if success
      success
    end

    # Unequip the item
    # @param mob [Mob] Mob unequipping the item
    # @return [Boolean] Success
    def unequip(mob)
      return false unless @equipped

      mob.unequip_item(self)
      @equipped = false
      on_unequip(mob)
      true
    end

    # Add item to container
    # @param item [Item] Item to add
    # @return [Boolean] Success
    def add_item(item)
      return false unless @is_container
      return false if @contents.include?(item)

      @contents << item
      true
    end

    # Remove item from container
    # @param item [Item] Item to remove
    # @return [Boolean] Success
    def remove_item(item)
      return false unless @contents.include?(item)

      @contents.delete(item)
      true
    end

    # Called when item is picked up
    # @param mob [Mob] Mob that picked it up
    def on_pickup(mob); end

    # Called when item is dropped
    # @param mob [Mob] Mob that dropped it
    # @param position [Position] Drop position
    def on_drop(mob, position); end

    # Called when item is equipped
    # @param mob [Mob] Mob that equipped it
    def on_equip(mob); end

    # Called when item is unequipped
    # @param mob [Mob] Mob that unequipped it
    def on_unequip(mob); end

    # Check if item is broken
    # @return [Boolean]
    def broken?
      @condition <= 0
    end

    # Damage the item
    # @param amount [Integer] Damage amount
    def damage(amount)
      return if broken?

      @condition -= amount
      on_damaged(amount) if @condition <= 0
    end

    # Called when item is damaged
    # @param amount [Integer] Damage amount
    def on_damaged(amount); end

    # Repair the item
    # @param amount [Integer] Repair amount
    def repair(amount)
      return if broken?

      @condition = [@condition + amount, @max_condition].min
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        weight: @weight,
        volume: @volume,
        category: @category,
        equippable: @equippable,
        equip_slot: @equip_slot,
        equipped: @equipped,
        condition: @condition,
        max_condition: @max_condition,
        is_container: @is_container,
        contents: @contents.map(&:serialize)
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Item]
    def self.deserialize(data)
      item = new(
        weight: data.fetch('weight', 100),
        volume: data.fetch('volume', 100),
        category: data.fetch('category', 'misc'),
        equippable: data.fetch('equippable', false),
        equip_slot: data.fetch('equip_slot'),
        equipped: data.fetch('equipped', false),
        condition: data.fetch('condition', 100),
        max_condition: data.fetch('max_condition', 100),
        is_container: data.fetch('is_container', false),
        **data.slice('name', 'description', 'position').to_h
      )

      # Deserialize contents
      if data['contents']
        data['contents'].each do |content_data|
          item.add_item(deserialize(content_data))
        end
      end

      item
    end
  end
end