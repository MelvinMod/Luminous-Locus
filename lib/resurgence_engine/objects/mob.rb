# frozen_string_literal: true

module ResurgenceEngine
  # Mob class - living creatures/players
  #
  # Mobs have health, inventories, and can act.
  class Mob < Movable
    # @return [Integer] Mob health
    attr_accessor :health

    # @return [Integer] Max health
    attr_accessor :max_health

    # @return [Integer] Mob status flags
    attr_accessor :status_flags

    # @return [Inventory, nil] Mob's inventory
    attr_accessor :inventory

    # @return [Hash<Symbol, Item>] Equipped items
    attr_reader :equipment

    # @return [Integer] Hunger level (0-100)
    attr_accessor :hunger

    # @return [Integer] Thirst level (0-100)
    attr_accessor :thirst

    # @return [Integer] Stamina level (0-100)
    attr_accessor :stamina

    # @return [Integer] Oxygen level (0-100)
    attr_accessor :oxygen

    # @return [Integer] Body temperature
    attr_accessor :body_temperature

    # @return [Integer] Blood volume
    attr_accessor :blood_volume

    # @return [Integer] Brute damage
    attr_accessor :brute_damage

    # @return [Integer] Burn damage
    attr_accessor :burn_damage

    # @return [Integer] Toxin damage
    attr_accessor :toxin_damage

    # @return [Integer] Oxyloss
    attr_accessor :oxyloss

    # @return [Array<Symbol>] Mutations
    attr_reader :mutations

    # @return [String, nil] Mob species
    attr_accessor :species

    # @return [String, nil] Mob job/profession
    attr_accessor :job

    # @return [Integer] Mob age in seconds
    attr_accessor :age

    # @return [Array<SpeechAct>] Recent speech acts
    attr_reader :speech_acts

    # Initialize a new mob
    def initialize(
      health: 100,
      max_health: 100,
      status_flags: 0,
      hunger: 100,
      thirst: 100,
      stamina: 100,
      oxygen: 100,
      body_temperature: 310,  # ~37°C
      blood_volume: 5000,
      brute_damage: 0,
      burn_damage: 0,
      toxin_damage: 0,
      oxyloss: 0,
      species: 'human',
      job: nil,
      **kwargs
    )
      super(**kwargs)
      @health = health
      @max_health = max_health
      @status_flags = status_flags
      @inventory = nil
      @equipment = {}
      @hunger = hunger
      @thirst = thirst
      @stamina = stamina
      @oxygen = oxygen
      @body_temperature = body_temperature
      @blood_volume = blood_volume
      @brute_damage = brute_damage
      @burn_damage = burn_damage
      @toxin_damage = toxin_damage
      @oxyloss = oxyloss
      @mutations = []
      @species = species
      @job = job
      @age = 0
      @speech_acts = []

      add_tag(:mob)
    end

    # Create default inventory
    # @param size [Integer] Inventory slots
    def create_inventory(size = 20)
      @inventory = Inventory.new(size)
    end

    # Equip item to slot
    # @param item [Item] Item to equip
    # @param slot [Symbol] Slot name
    # @return [Boolean] Success
    def equip_item(item, slot = nil)
      slot ||= item.equip_slot
      return false unless slot

      @equipment[slot] = item
      item.equipped = true
      true
    end

    # Unequip item
    # @param item [Item] Item to unequip
    # @return [Boolean] Success
    def unequip_item(item)
      @equipment.each do |slot, equipped_item|
        if equipped_item == item
          @equipment.delete(slot)
          item.equipped = false
          return true
        end
      end
      false
    end

    # Get item in equipment slot
    # @param slot [Symbol] Slot name
    # @return [Item, nil]
    def get_equipped(slot)
      @equipment[slot]
    end

    # Check if status flag is set
    # @param flag [Integer] Status flag
    # @return [Boolean]
    def status_flag?(flag)
      @status_flags & flag != 0
    end

    # Set status flag
    # @param flag [Integer] Status flag
    def set_status(flag)
      @status_flags |= flag
    end

    # Clear status flag
    # @param flag [Integer] Status flag
    def clear_status(flag)
      @status_flags &= ~flag
    end

    # Apply damage to mob
    # @param amount [Integer] Damage amount
    # @param type [Symbol] Damage type (:brute, :burn, :toxin, :oxygen)
    def take_damage(amount, type = :brute)
      case type
      when :brute
        @brute_damage += amount
      when :burn
        @burn_damage += amount
      when :toxin
        @toxin_damage += amount
      when :oxygen
        @oxyloss += amount
      end
      update_health
    end

    # Update health based on damage
    def update_health
      total_damage = @brute_damage + @burn_damage + @toxin_damage + @oxyloss
      @health = [@max_health - total_damage, 0].max

      check_death if @health <= 0
    end

    # Heal mob
    # @param amount [Integer] Healing amount
    # @param type [Symbol, nil] Damage type to heal
    def heal(amount, type = nil)
      if type
        case type
        when :brute
          @brute_damage = [@brute_damage - amount, 0].max
        when :burn
          @burn_damage = [@burn_damage - amount, 0].max
        when :toxin
          @toxin_damage = [@toxin_damage - amount, 0].max
        when :oxygen
          @oxyloss = [@oxyloss - amount, 0].max
        end
      else
        @brute_damage = [@brute_damage - amount / 4, 0].max
        @burn_damage = [@burn_damage - amount / 4, 0].max
        @toxin_damage = [@toxin_damage - amount / 4, 0].max
        @oxyloss = [@oxyloss - amount / 4, 0].max
      end
      update_health
    end

    # Check if mob is dead
    # @return [Boolean]
    def dead?
      @health <= 0
    end

    # Check if mob is unconscious
    # @return [Boolean]
    def unconscious?
      @health <= 0 || status_flag?(StatusFlags::UNCONSCIOUS)
    end

    # Check if mob is sleeping
    # @return [Boolean]
    def sleeping?
      status_flag?(StatusFlags::SLEEPING)
    end

    # Check if mob is resting
    # @return [Boolean]
    def resting?
      status_flag?(StatusFlags::RESTING)
    end

    # Add mutation
    # @param mutation [Symbol] Mutation to add
    def add_mutation(mutation)
      @mutations << mutation unless @mutations.include?(mutation)
    end

    # Remove mutation
    # @param mutation [Symbol] Mutation to remove
    def remove_mutation(mutation)
      @mutations.delete(mutation)
    end

    # Check for mutation
    # @param mutation [Symbol] Mutation to check
    # @return [Boolean]
    def has_mutation?(mutation)
      @mutations.include?(mutation)
    end

    # Add speech act
    # @param speech [SpeechAct] Speech to add
    def add_speech_act(speech)
      @speech_acts << speech
      @speech_acts.shift if @speech_acts.size > 10
    end

    # Get recent speech
    # @param limit [Integer] Max number to return
    # @return [Array<SpeechAct>]
    def recent_speech(limit = 5)
      @speech_acts.last(limit)
    end

    # Tick mob life processes
    # @param delta [Float] Time since last tick
    def tick(delta)
      super

      @age += delta

      # Life processes
      process_hunger(delta)
      process_thirst(delta)
      process_oxygen(delta)
      process_temperature(delta)
    end

    # Process hunger
    # @param delta [Float] Time since last tick
    def process_hunger(delta)
      @hunger -= delta * 0.5  # Lose 0.5 hunger per second
      @hunger = [@hunger, 0].max

      if @hunger <= 0
        take_damage(delta * 2, :brute)  # Starvation damage
      end
    end

    # Process thirst
    # @param delta [Float] Time since last tick
    def process_thirst(delta)
      @thirst -= delta * 0.8  # Lose 0.8 thirst per second
      @thirst = [@thirst, 0].max

      if @thirst <= 0
        take_damage(delta * 3, :brute)  # Dehydration damage
      end
    end

    # Process oxygen
    # @param delta [Float] Time since last tick
    def process_oxygen(delta)
      @oxygen -= delta * 1.0  # Lose 1.0 oxygen per second
      @oxygen = [@oxygen, 0].max

      if @oxygen <= 0
        @oxyloss += delta * 10
        update_health
      end
    end

    # Process body temperature
    # @param delta [Float] Time since last tick
    def process_temperature(delta)
      # Normal body temp is ~310K
      if @body_temperature < 250  # Freezing
        take_damage(delta * 5, :brute)
      elsif @body_temperature > 350  # Burning
        take_damage(delta * 5, :burn)
      end
    end

    # Eat food
    # @param food [Item] Food item
    # @return [Boolean] Success
    def eat(food)
      return false unless food.tagged?(:food)

      @hunger = [@hunger + food.nutrition_value, 100].min
      @thirst = [@thirst + food.hydration_value, 100].min if food.respond_to?(:hydration_value)
      food.quantity -= 1
      true
    end

    # Drink liquid
    # @param liquid [Item] Drinkable item
    # @return [Boolean] Success
    def drink(liquid)
      return false unless liquid.tagged?(:drink)

      @thirst = [@thirst + liquid.thirst_value, 100].min
      true
    end

    # Breathe
    # @param gas_mixture [Integer] Gas mixture to breathe
    # @param pressure [Integer] Pressure
    def breathe(gas_mixture, pressure)
      # Process breathing based on gas mixture
      if gas_mixture & GasTypes::OXYGEN != 0
        @oxygen = [@oxygen + 10, 100].min
      end

      if pressure < 50000  # Low pressure damage
        take_damage((50000 - pressure) / 1000, :toxin)
      end
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      super.merge(
        health: @health,
        max_health: @max_health,
        status_flags: @status_flags,
        hunger: @hunger,
        thirst: @thirst,
        stamina: @stamina,
        oxygen: @oxygen,
        body_temperature: @body_temperature,
        blood_volume: @blood_volume,
        brute_damage: @brute_damage,
        burn_damage: @burn_damage,
        toxin_damage: @toxin_damage,
        oxyloss: @oxyloss,
        mutations: @mutations.dup,
        species: @species,
        job: @job,
        age: @age,
        equipment: @equipment.transform_values { |v| v&.id&.id }
      )
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Mob]
    def self.deserialize(data)
      mob = new(
        health: data.fetch('health', 100),
        max_health: data.fetch('max_health', 100),
        status_flags: data.fetch('status_flags', 0),
        hunger: data.fetch('hunger', 100),
        thirst: data.fetch('thirst', 100),
        stamina: data.fetch('stamina', 100),
        oxygen: data.fetch('oxygen', 100),
        body_temperature: data.fetch('body_temperature', 310),
        blood_volume: data.fetch('blood_volume', 5000),
        brute_damage: data.fetch('brute_damage', 0),
        burn_damage: data.fetch('burn_damage', 0),
        toxin_damage: data.fetch('toxin_damage', 0),
        oxyloss: data.fetch('oxyloss', 0),
        species: data.fetch('species', 'human'),
        job: data.fetch('job'),
        **data.slice('name', 'description', 'position').to_h
      )
      mob.instance_variable_set(:@mutations, data['mutations'] || [])
      mob.instance_variable_set(:@age, data['age'] || 0)
      mob
    end
  end

  # Status flags module
  module StatusFlags
    NONE = 0
    UNCONSCIOUS = 1
    SLEEPING = 2
    RESTING = 4
    DEAD = 8
    EDITING = 16
    SPEAKING = 32
    STUNNED = 64
    KNOCKED_DOWN = 128
    PARALYZED = 256
    IMMOBILIZED = 512
    BLIND = 1024
    DEAF = 2048
    MUTED = 4096
  end

  # Inventory class
  class Inventory
    # @return [Integer] Max slots
    attr_reader :max_slots

    # @return [Array<Item, nil>] Items in inventory
    attr_reader :items

    # @return [Integer] Current weight
    attr_reader :current_weight

    # @return [Integer] Max weight
    attr_reader :max_weight

    # @return [Integer] Current volume
    attr_reader :current_volume

    # @return [Integer] Max volume
    attr_reader :max_volume

    def initialize(max_slots = 20, max_weight = 30_000, max_volume = 30_000)
      @max_slots = max_slots
      @max_weight = max_weight
      @max_volume = max_volume
      @items = Array.new(max_slots, nil)
      @current_weight = 0
      @current_volume = 0
    end

    # Add item to inventory
    # @param item [Item] Item to add
    # @return [Boolean] Success
    def add(item)
      return false if full?
      return false if overweight?(item.total_weight)
      return false if overvolumed?(item.total_volume)

      empty_slot = @items.index(nil)
      return false unless empty_slot

      @items[empty_slot] = item
      update_totals
      true
    end

    # Remove item from inventory
    # @param item [Item] Item to remove
    # @return [Boolean] Success
    def remove(item)
      index = @items.index(item)
      return false unless index

      @items[index] = nil
      update_totals
      true
    end

    # Check if inventory contains item
    # @param item [Item] Item to check
    # @return [Boolean]
    def contains?(item)
      @items.include?(item)
    end

    # Get item at index
    # @param index [Integer] Slot index
    # @return [Item, nil]
    def [](index)
      @items[index]
    end

    # Set item at index
    # @param index [Integer] Slot index
    # @param item [Item, nil] Item to set
    def []=(index, item)
      old_item = @items[index]
      @items[index] = item
      update_totals
    end

    # Check if inventory is full
    # @return [Boolean]
    def full?
      @items.none?(nil)
    end

    # Get empty slots
    # @return [Integer]
    def empty_slots
      @items.count(nil)
    end

    # Check if would be overweight
    # @param weight [Integer] Weight to check
    # @return [Boolean]
    def overweight?(weight)
      @current_weight + weight > @max_weight
    end

    # Check if would be overvolumed
    # @param volume [Integer] Volume to check
    # @return [Boolean]
    def overvolumed?(volume)
      @current_volume + volume > @max_volume
    end

    # Update weight and volume totals
    def update_totals
      @current_weight = @items.compact.sum(&:total_weight)
      @current_volume = @items.compact.sum(&:total_volume)
    end

    # Find items by category
    # @param category [String] Category to find
    # @return [Array<Item>]
    def find_by_category(category)
      @items.compact.select { |item| item.category == category }
    end

    # Find items by tag
    # @param tag [Symbol] Tag to find
    # @return [Array<Item>]
    def find_by_tag(tag)
      @items.compact.select { |item| item.tagged?(tag) }
    end

    # Serialize to hash
    # @return [Hash]
    def serialize
      {
        items: @items.compact.map(&:serialize),
        max_slots: @max_slots,
        max_weight: @max_weight,
        max_volume: @max_volume
      }
    end

    # Deserialize from hash
    # @param data [Hash] Serialized data
    # @return [Inventory]
    def self.deserialize(data)
      inv = new(
        data['max_slots'] || 20,
        data['max_weight'] || 30_000,
        data['max_volume'] || 30_000
      )

      data['items']&.each_with_index do |item_data, index|
        inv[index] = Item.deserialize(item_data) if item_data
      end

      inv
    end
  end
end