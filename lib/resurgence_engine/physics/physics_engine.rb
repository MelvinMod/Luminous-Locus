# frozen_string_literal: true

module ResurgenceEngine
  # Physics engine for collision and movement
  #
  # Handles collision detection, gravity, and physical interactions.
  module PhysicsEngine
    # Collision types
    COLLISION_NONE = 0
    COLLISION_SOLID = 1
    COLLISION_PASSABLE = 2
    COLLISION_HITBOX = 4

    # Physics flags
    FLAG_NONE = 0
    FLAG_GRAVITY = 1
    FLAG_FLOATING = 2
    FLAG_NO_COLLISION = 4
    FLAG_SLIDE = 8
    FLAG_BOUNCY = 16

    # Collision result
    CollisionResult = Data.define(
      :collided,
      :normal,
      :penetration,
      :object
    )

    class << self
      # Global physics settings
      attr_accessor :gravity
      attr_accessor :air_resistance
      attr_accessor :terminal_velocity
      attr_accessor :time_scale

      # Initialize physics
      def init
        @gravity = 9.8
        @air_resistance = 0.1
        @terminal_velocity = 50.0
        @time_scale = 1.0
      end
    end

    init

    # Check collision at position
    # @param position [Position] Position to check
    # @param map [Map] Map to check on
    # @param size [Integer] Object size
    # @return [Array<Object>] Colliding objects
    def self.check_collision(position, map, size = 1)
      return [] unless map

      colliding = []
      (position.x - size..position.x + size).each do |x|
        (position.y - size..position.y + size).each do |y|
          (position.z - size..position.z + size).each do |z|
            pos = Position[x, y, z]
            next unless map.valid_position?(pos)

            obj = map.get_cell(pos)
            next unless obj
            next unless obj.tagged?(:solid)

            colliding << obj
          end
        end
      end
      colliding
    end

    # Raycast for collision
    # @param start [Position] Start position
    # @param direction [Array<Float>] Direction vector
    # @param map [Map] Map to check on
    # @param max_distance [Float] Maximum distance
    # @return [CollisionResult, nil]
    def self.raycast(start, direction, map, max_distance = 10.0)
      return nil unless map

      step_size = 0.1
      current = start.dup

      (max_distance / step_size).to_i.times do
        return nil if check_collision(current, map, 1).empty?

        current.x += direction[0] * step_size
        current.y += direction[1] * step_size
        current.z += direction[2] * step_size
      end

      CollisionResult.new(
        collided: false,
        normal: [0, 0, 0],
        penetration: 0,
        object: nil
      )
    end

    # Calculate movement with collision
    # @param obj [Movable] Moving object
    # @param velocity [Array<Float>] Velocity vector
    # @param map [Map] Map to check on
    # @return [Array<Float>] Adjusted velocity
    def self.resolve_collision(obj, velocity, map)
      return velocity if obj.movement_locked?

      # Simple axis-aligned collision
      adjusted = velocity.dup

      # Check X movement
      new_pos_x = Position[
        obj.position.x + adjusted[0],
        obj.position.y,
        obj.position.z
      ]
      if map.valid_position?(new_pos_x) && !blocked?(new_pos_x, map)
        obj.position.x = new_pos_x.x
      else
        adjusted[0] = 0
      end

      # Check Y movement
      new_pos_y = Position[
        obj.position.x,
        obj.position.y + adjusted[1],
        obj.position.z
      ]
      if map.valid_position?(new_pos_y) && !blocked?(new_pos_y, map)
        obj.position.y = new_pos_y.y
      else
        adjusted[1] = 0
      end

      # Check Z movement (gravity)
      new_pos_z = Position[
        obj.position.x,
        obj.position.y,
        obj.position.z + adjusted[2]
      ]
      if map.valid_position?(new_pos_z) && !blocked?(new_pos_z, map)
        obj.position.z = new_pos_z.z
      else
        adjusted[2] = 0
      end

      adjusted
    end

    # Check if position is blocked
    # @param position [Position] Position to check
    # @param map [Map] Map to check on
    # @return [Boolean]
    def self.blocked?(position, map)
      return true unless map.valid_position?(position)

      obj = map.get_cell(position)
      return false if obj.nil?
      return true if obj.tagged?(:solid)

      false
    end

    # Apply gravity
    # @param obj [Movable] Object to apply gravity to
    # @param delta [Float] Time since last tick
    def self.apply_gravity(obj, delta)
      return if obj.status_flag?(PhysicsEngine::FLAG_FLOATING)

      velocity = [0, 0, -@gravity * delta * @time_scale]
      resolve_collision(obj, velocity, obj.map)
    end

    # Apply velocity
    # @param obj [Movable] Object to apply velocity to
    # @param velocity [Array<Float>] Velocity vector
    # @param map [Map] Map to check on
    def self.apply_velocity(obj, velocity, map)
      resolve_collision(obj, velocity, map)
    end

    # Check if position is valid for placement
    # @param position [Position] Position to check
    # @param map [Map] Map to check on
    # @param size [Integer] Object size
    # @return [Boolean]
    def self.valid_placement?(position, map, size = 1)
      return false unless map.valid_position?(position)

      (position.x - size..position.x + size).each do |x|
        (position.y - size..position.y + size).each do |y|
          (position.z - size..position.z + size).each do |z|
            pos = Position[x, y, z]
            next unless map.valid_position?(pos)

            obj = map.get_cell(pos)
            return false if obj && !obj.tagged?(:passable)
          end
        end
      end
      true
    end

    # Calculate distance with physics
    # @param pos1 [Position] First position
    # @param pos2 [Position] Second position
    # @return [Float] Distance
    def self.distance(pos1, pos2)
      Math.sqrt(
        (pos1.x - pos2.x)**2 +
        (pos1.y - pos2.y)**2 +
        (pos1.z - pos2.z)**2
      )
    end

    # Calculate angle between positions
    # @param from [Position] Source position
    # @param to [Position] Target position
    # @return [Float] Angle in radians
    def self.angle(from, to)
      Math.atan2(to.y - from.y, to.x - from.x)
    end

    # Projectile motion calculation
    # @param start [Position] Starting position
    # @param velocity [Array<Float>] Initial velocity
    # @param gravity [Float] Gravity value
    # @param max_steps [Integer] Maximum steps
    # @return [Array<Position>] Trajectory
    def self.calculate_trajectory(start, velocity, gravity = @gravity, max_steps = 100)
      trajectory = [start.dup]
      pos = start.dup
      vel = velocity.dup
      dt = 0.1

      max_steps.times do
        pos.x += vel[0] * dt
        pos.y += vel[1] * dt
        pos.z += vel[2] * dt
        vel[2] -= gravity * dt

        trajectory << pos.dup
      end

      trajectory
    end

    # Calculate throw arc
    # @param start [Position] Starting position
    # @param target [Position] Target position
    # @param speed [Float] Throw speed
    # @return [Array<Float>] Initial velocity
    def self.calculate_throw_velocity(start, target, speed = 10.0)
      dx = target.x - start.x
      dy = target.y - start.y
      dz = target.z - start.z

      # Calculate required velocities
      distance = Math.sqrt(dx**2 + dy**2)
      time = distance / speed

      vx = dx / time
      vy = dy / time
      vz = (dz + 0.5 * @gravity * time**2) / time

      [vx, vy, vz]
    end

    # Calculate explosion effects
    # @param center [Position] Explosion center
    # @param radius [Float] Explosion radius
    # @param map [Map] Map to apply to
    # @param damage [Integer] Base damage
    # @return [Array<Object>] Affected objects
    def self.explode(center, radius, map, damage = 50)
      affected = []

      (center.x - radius..center.x + radius).each do |x|
        (center.y - radius..center.y + radius).each do |y|
          (center.z - radius..center.z + radius).each do |z|
            pos = Position[x, y, z]
            next unless map.valid_position?(pos)

            dist = distance(center, pos)
            next if dist > radius

            obj = map.get_cell(pos)
            next unless obj

            # Calculate damage based on distance
            falloff = 1.0 - (dist / radius)
            obj_damage = (damage * falloff).to_i

            if obj.respond_to?(:damage)
              obj.damage(obj_damage)
              affected << obj
            end

            # Push objects
            if obj.respond_to?(:position)
              push_direction = [
                (pos.x - center.x) / dist,
                (pos.y - center.y) / dist,
                (pos.z - center.z) / dist
              ]
              obj.position.x += push_direction[0].to_i
              obj.position.y += push_direction[1].to_i
              obj.position.z += push_direction[2].to_i
            end
          end
        end
      end

      affected
    end

    # Check line of sight with physics
    # @param start [Position] Start position
    # @param end_pos [Position] End position
    # @param map [Map] Map to check on
    # @return [Boolean] Clear path
    def self.clear_path?(start, end_pos, map)
      return false unless start && end_pos && map

      steps = distance(start, end_pos).to_i * 2
      return false if steps.zero?

      dx = (end_pos.x - start.x) / steps.to_f
      dy = (end_pos.y - start.y) / steps.to_f
      dz = (end_pos.z - start.z) / steps.to_f

      steps.times do |i|
        pos = Position[
          (start.x + dx * i).round,
          (start.y + dy * i).round,
          (start.z + dz * i).round
        ]
        return false if blocked?(pos, map)
      end

      true
    end

    # Serialize physics state
    # @return [Hash]
    def self.serialize
      {
        gravity: @gravity,
        air_resistance: @air_resistance,
        terminal_velocity: @terminal_velocity,
        time_scale: @time_scale
      }
    end

    # Deserialize physics state
    # @param data [Hash] Serialized data
    def self.deserialize(data)
      @gravity = data['gravity'] || 9.8
      @air_resistance = data['air_resistance'] || 0.1
      @terminal_velocity = data['terminal_velocity'] || 50.0
      @time_scale = data['time_scale'] || 1.0
    end
  end
end