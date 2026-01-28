# ResurgenceEngine World Class
# Main game world container
# 
# Manages maps, objects, systems,
# and game tick logic

module ResurgenceEngine
  class World
    attr_reader :active_map, :objects, :running, :tick_count
    attr_accessor :tick_rate

    # Create new world
    def initialize
      @maps = {}
      @active_map = nil
      @objects = {}
      @running = false
      @tick_rate = 20
      @tick_count = 0
      @systems = []

      @data = {}
      @next_map_id = 0
    end

    # Create new map
    def create_map(name, w = 100, h = 100, d = 1)
      map_id = @next_map_id += 1
      @maps[map_id] = Map.new(w, h, 1, name)
      @active_map = @maps[map_id]
      @active_map.loaded = true
      puts "Map created: #{name} #{w}x#{h}x#{d}"
      @active_map
    end

    # Get all maps
    def all_maps
      @maps.values
    end

    # Get map by id
    def get_map(id)
      @maps[id]
    end

    # Get map by name
    def get_map_by_name(name)
      @maps.values.find { |m| m.name == name }
    end

    # Delete map
    def delete_map(id)
      return unless @maps[id]
      @maps.delete(id)
      @active_map = @maps.values.first if @active_map == @maps[id]
    end

    # Clear all maps
    def clear_maps
      @maps.clear
      @active_map = nil
    end

    # Get object by id
    def get_object_by_id(id)
      @objects[id]
    end

    # Get all objects of class
    def get_all_objects(klass = Object)
      return @objects.values unless klass
      @objects.values.select { |o| o.is_a?(klass) }
    end

    # Add object to world
    def add_object(obj)
      return if @objects.key?(obj.id)
      @objects[obj.id] = obj
      obj.instance_variable_set(:@world, self)
    end

    # Remove object from world
    def remove_object(obj)
      @objects.delete(obj.id)
    end

    # Delete object
    def delete_object(id)
      obj = @objects[id]
      return unless obj
      obj.delete
      @objects.delete(id)
    end

    # Start world
    def start
      @running = true
      puts 'World started'
    end

    # Stop world
    def stop
      @running = false
      puts 'World stopped'
    end

    # Tick world
    def tick(dt)
      return unless @running

      @tick_count += 1
      @systems.each { |s| s.tick(dt) }
      @objects.each { |_, o| o.tick(dt) }
    end

    # Add system
    def add_system(system)
      @systems << system
    end

    # Get data
    def get_data(key)
      @data[key]
    end

    # Set data
    def set_data(key, value)
      @data[key] = value
    end

    # Clear world
    def clear
      @objects.clear
      @maps.clear
      @active_map = nil
      @data.clear
    end

    # Serialize world
    def serialize
      {
        maps: @maps.values.map(&:serialize),
        active_map_id: @active_map&.object_id,
        tick_count: @tick_count
      }
    end

    # Deserialize world
    def self.deserialize(data)
      w = new
      data['maps'].each do |m|
        map = Map.deserialize(m)
        w.maps[map.object_id] = map
      end
      w
    end

    # Get world stats
    def stats
      {
        maps: @maps.size,
        objects: @objects.size,
        running: @running,
        tick_count: @tick_count,
        tick_rate: @tick_rate
      }
    end
  end
end