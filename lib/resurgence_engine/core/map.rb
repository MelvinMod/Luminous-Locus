module ResurgenceEngine
  class Map
    attr_reader :width, :height, :depth, :name, :description
    attr_reader :grid, :objects, :objects_by_tag, :los_calculator
    attr_accessor :loaded

    def initialize(w = 100, h = 100, d = 1, name = 'map')
      raise ArgumentError, 'bad width' unless w.positive?
      raise ArgumentError, 'bad height' unless h.positive?
      raise ArgumentError, 'bad depth' unless d.positive?

      @width = w
      @height = h
      @depth = d
      @name = name
      @description = nil
      @loaded = false

      init_grid
      init_cols
      @los_calculator = LosCalculator.new
    end

    def init_grid
      @grid = Array.new(@depth) { Array.new(@height) { Array.new(@width) } }
    end

    def init_cols
      @objects = {}
      @objects_by_tag = {}
    end

    def valid_pos?(pos)
      return false unless pos
      return false unless pos.x.between?(0, @width - 1)
      return false unless pos.y.between?(0, @height - 1)
      return false unless pos.z.between?(0, @depth - 1)
      true
    end

    def get_cell(pos)
      return nil unless valid_pos?(pos)
      @grid[pos.z][pos.y][pos.x]
    end

    def set_cell(pos, obj)
      return nil unless valid_pos?(pos)

      prev = @grid[pos.z][pos.y][pos.x]
      return prev if prev == obj

      remove_from_cols(prev) if prev
      add_to_cols(obj) if obj

      @grid[pos.z][pos.y][pos.x] = obj
      obj&.on_add_to_map(self) if obj

      prev
    end

    def add_object(pos, obj)
      return false if get_cell(pos)
      return false unless valid_pos?(pos)

      obj.id = IdPtr.generate(obj.class) unless obj.id&.valid?
      set_cell(pos, obj)
      true
    end

    def remove_object(pos)
      obj = get_cell(pos)
      return nil unless obj

      obj.on_remove_from_map(self)
      set_cell(pos, nil)
      obj
    end

    def occupied?(pos)
      !get_cell(pos).nil?
    end

    def get_objects(klass: nil, tag: nil)
      res = @objects.values
      res.select! { |o| o.is_a?(klass) } if klass
      res.select! { |o| o.tagged?(tag) } if tag
      res
    end

    def get_object_by_id(id)
      @objects[id]
    end

    def get_objects_at(pos)
      obj = get_cell(pos)
      obj ? [obj] : []
    end

    def get_neighbors(pos, dirs = Direction::ALL)
      n = {}
      dirs.each do |dir|
        np = pos.neighbor(dir)
        n[dir] = np if valid_pos?(np)
      end
      n
    end

    def get_cardinal_neighbors(pos)
      get_neighbors(pos, Direction::CARDINAL)
    end

    def direction_clear?(pos, dir)
      np = pos.neighbor(dir)
      valid_pos?(np) && !occupied?(np)
    end

    def find_all(&pred)
      res = []
      @depth.times do |z|
        @height.times do |y|
          @width.times do |x|
            p = Position[x, y, z]
            o = get_cell(p)
            res << p if pred.call(p, o)
          end
        end
      end
      res
    end

    def find(&pred)
      @depth.times do |z|
        @height.times do |y|
          @width.times do |x|
            p = Position[x, y, z]
            o = get_cell(p)
            return p if pred.call(p, o)
          end
        end
      end
      nil
    end

    def count_objects(klass: nil, tag: nil)
      get_objects(klass: klass, tag: tag).size
    end

    def all_positions
      @depth.times.flat_map do |z|
        @height.times.flat_map do |y|
          @width.times.map { |x| Position[x, y, z] }
        end
      end
    end

    def random_position(&pred)
      pos = if pred
        all_positions.select { |p| pred.call(p, get_cell(p)) }
      else
        all_positions
      end
      pos.sample
    end

    def get_visible_cells(pos, range = 8)
      @los_calculator.get_visible_cells(pos, range, self)
    end

    def has_los?(from, to)
      @los_calculator.has_los?(from, to, self)
    end

    def add_to_cols(obj)
      return unless obj
      @objects[obj.id] = obj
      obj.tags.each_key do |tag|
        @objects_by_tag[tag] ||= []
        @objects_by_tag[tag] << obj
      end
    end

    def remove_from_cols(obj)
      return unless obj
      @objects.delete(obj.id)
      obj.tags.each_key do |tag|
        @objects_by_tag[tag]&.delete(obj)
      end
    end

    def get_objects_by_tag(tag)
      @objects_by_tag[tag] || []
    end

    def clear
      @depth.times do |z|
        @height.times do |y|
          @width.times { |x| @grid[z][y][x] = nil }
        end
      end
      init_cols
    end

    def resize(w, h, d)
      old = @grid
      init_grid

      [0, @depth].min.times do |z|
        [0, @height].min.times do |y|
          [0, @width].min.times do |x|
            @grid[z][y][x] = old[z][y][x] if old[z] && old[z][y]
          end
        end
      end

      @width = w
      @height = h
      @depth = d
    end

    def stats
      {
        name: @name,
        dims: "#{@width}x#{@height}x#{@depth}",
        obj_count: @objects.size,
        by_tag: @objects_by_tag.transform_values(&:size)
      }
    end

    def inspect
      "#<Map #{@name} #{@width}x#{@height}x#{@depth}>"
    end

    def serialize
      {
        name: @name,
        description: @description,
        width: @width,
        height: @height,
        depth: @depth,
        grid: serialize_grid,
        objects: @objects.values.map(&:serialize)
      }
    end

    def serialize_grid
      @depth.times.map do |z|
        @height.times.map do |y|
          @width.times.map do |x|
            obj = @grid[z][y][x]
            { type: obj&.object_type, id: obj&.id&.id }
          end
        end
      end
    end

    def self.deserialize(data)
      m = new(data['width'], data['height'], data['depth'], data['name'])
      m.description = data['description']
      m
    end
  end
end