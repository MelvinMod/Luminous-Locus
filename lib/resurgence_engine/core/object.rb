# ResurgenceEngine Base Object Class
# Base class for all game objects
# 
# Handles object identity, tags, health,
# components, and serialization

module ResurgenceEngine
  class Object
    attr_reader :id, :tags, :data, :components
    attr_accessor :name, :description, :initialized, :deleted
    attr_accessor :health, :max_health

    # Class instances registry
    @@instances = {}

    # Create new object
    def initialize(id: nil, name: nil)
      @id = id || IdPtr.generate(self.class)
      @name = name
      @description = nil
      @tags = {}
      @data = {}
      @components = []
      @initialized = false
      @deleted = false
      @health = 0
      @max_health = 0
      @health_percentage = 1.0

      (@@instances[self.class] ||= []) << self
    end

    # Get all instances
    def self.instances
      @@instances
    end

    # Get health percentage
    def health_percentage
      @max_health > 0 ? @health.to_f / @max_health : 0.0
    end

    # Check if alive
    def alive?
      @alive != false && @health > 0
    end

    # Check if tagged
    def tagged?(tag)
      @tags.key?(tag)
    end

    # Add tag
    def add_tag(tag, val = true)
      @tags[tag] = val
    end

    # Remove tag
    def remove_tag(tag)
      @tags.delete(tag)
    end

    # Get tag value
    def get_tag(tag, default = nil)
      @tags[tag] || default
    end

    # Set health
    def set_health(amount, max = nil)
      @health = amount
      @max_health = max if max
      @health_percentage = @max_health > 0 ? @health.to_f / @max_health : 0.0
    end

    # Modify health
    def modify_health(amount)
      @health = [@health + amount, @max_health].min
      @health = [@health, 0].max
      @health_percentage = @max_health > 0 ? @health.to_f / @max_health : 0.0
      check_death if amount < 0
    end

    # Check death
    def check_death
      if @health <= 0
        @alive = false
        on_death
      end
    end

    # On death callback
    def on_death
      @alive = false
    end

    # Delete object
    def delete
      @deleted = true
      on_deleted
    end

    # On deleted callback
    def on_deleted
      (@@instances[self.class] ||= []).delete(self)
    end

    # On add to map callback
    def on_add_to_map(map); end
    
    # On remove from map callback
    def on_remove_from_map(map); end
    
    # Tick callback
    def tick(delta); end
    
    # On component added callback
    def on_component_added(comp); end

    # Add component
    def add_component(comp)
      return if @components.include?(comp)
      @components << comp
      on_component_added(comp)
    end

    # Check if has component
    def has_component?(comp)
      @components.include?(comp)
    end

    # Get view info
    def get_view_info
      Types::EMPTY_VIEW
    end

    # Get object type
    def object_type
      self.class.name
    end

    # Inspect object
    def inspect
      "#<#{self.class.name}:#{@id.id} name=#{@name.inspect}>"
    end

    # Equality check
    def ==(other)
      other.is_a?(Object) && @id == other.id
    end

    alias eql? ==

    # Hash
    def hash
      @id.hash
    end

    # Get all instances of class
    def self.all(klass = nil)
      return @@instances.values.flatten if klass.nil?
      @@instances[klass] || []
    end

    # Find by id
    def self.find_by_id(id)
      return nil unless id&.valid?
      @@instances.values.flatten.find { |o| o.id == id }
    end

    # Find by tag
    def self.find_by_tag(tag)
      @@instances.values.flatten.select { |o| o.tagged?(tag) }
    end

    # Serialize object
    def serialize
      {
        id: @id.id,
        type: object_type,
        name: @name,
        description: @description,
        tags: @tags,
        health: @health,
        max_health: @max_health,
        data: @data
      }
    end

    # Deserialize object
    def self.deserialize(data)
      obj = new(name: data['name'])
      obj.instance_variable_set(:@id, IdPtr.new(id: data['id'], type: obj.class))
      obj.description = data['description']
      obj.instance_variable_set(:@tags, data['tags'] || {})
      obj.set_health(data['health'] || 0, data['max_health'] || 0)
      obj
    end
  end
end