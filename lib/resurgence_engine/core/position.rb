module ResurgenceEngine
  Position = Data.define(:x, :y, :z) do
    def self.[](x, y, z = 0)
      new(x: x, y: y, z: z)
    end

    def neighbor(dir)
      case dir
      when Direction::WEST then self[x - 1, y, z]
      when Direction::EAST then self[x + 1, y, z]
      when Direction::NORTH then self[x, y - 1, z]
      when Direction::SOUTH then self[x, y + 1, z]
      when Direction::UP then self[x, y, z + 1]
      when Direction::DOWN then self[x, y, z - 1]
      else self
      end
    end

    def within?(w, h, d = 1)
      x.between?(0, w - 1) && y.between?(0, h - 1) && z.between?(0, d - 1)
    end

    def manhattan_distance(other)
      (x - other.x).abs + (y - other.y).abs + (z - other.z).abs
    end

    def euclidean_distance(other)
      Math.sqrt((x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2)
    end

    def to_a
      [x, y, z]
    end

    def inspect
      "(#{x}, #{y}, #{z})"
    end

    alias to_s inspect

    def ==(other)
      other.is_a?(Position) && x == other.x && y == other.y && z == other.z
    end

    def +(other)
      if other.is_a?(Position)
        self.class[x + other.x, y + other.y, z + other.z]
      else
        self.class[x + other[0], y + other[1], z + other[2] || 0]
      end
    end

    def -(other)
      if other.is_a?(Position)
        self.class[x - other.x, y - other.y, z - other.z]
      else
        self.class[x - other[0], y - other[1], z - other[2] || 0]
      end
    end
  end

  SqType = Position
end