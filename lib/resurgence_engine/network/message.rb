require 'json'

module ResurgenceEngine
  class Message
    TYPES = {
      handshake: 0x01,
      ping: 0x02,
      pong: 0x03,
      disconnect: 0x04,
      world_state: 0x10,
      map_state: 0x11,
      object_update: 0x12,
      object_create: 0x13,
      object_delete: 0x14,
      player_input: 0x20,
      player_move: 0x21,
      player_action: 0x22,
      player_say: 0x23,
      player_emote: 0x24,
      chat_message: 0x30,
      chat_private: 0x31,
      chat_channel: 0x32,
      admin_cmd: 0x40,
      admin_log: 0x41,
      error: 0xFF
    }.freeze

    attr_reader :type, :payload, :sender_id, :target_id, :timestamp, :sequence
    attr_accessor :reliable, :encrypted

    def initialize(type:, payload: {}, sender_id: nil, target_id: nil,
                   sequence: 0, reliable: true, encrypted: false)
      @type = type.is_a?(Symbol) ? TYPES[type] : type
      @payload = payload.dup
      @sender_id = sender_id
      @target_id = target_id
      @timestamp = Time.now.to_f
      @sequence = sequence
      @reliable = reliable
      @encrypted = encrypted
    end

    def type_symbol
      TYPES.key(@type) || :unknown
    end

    def [](key)
      @payload[key]
    end

    def []=(key, value)
      @payload[key] = value
    end

    def is_type?(type)
      @type == (type.is_a?(Symbol) ? TYPES[type] : type)
    end

    def serialize
      {
        t: @type,
        p: @payload,
        s: @sender_id&.id,
        r: @target_id&.id,
        ts: @timestamp,
        seq: @sequence,
        rel: @reliable,
        enc: @encrypted
      }.to_json
    end

    def self.deserialize(data)
      p = JSON.parse(data)
      Message.new(
        type: p['t'],
        payload: p['p'] || {},
        sender_id: p['s'] ? IdPtr.new(id: p['s'], type: nil) : nil,
        target_id: p['r'] ? IdPtr.new(id: p['r'], type: nil) : nil,
        sequence: p['seq'] || 0,
        reliable: p.fetch('rel', true),
        encrypted: p.fetch('enc', false)
      )
    end

    def self.ping(seq = 0)
      Message.new(type: :ping, payload: { seq: seq }, reliable: false)
    end

    def self.pong(seq = 0)
      Message.new(type: :pong, payload: { seq: seq }, reliable: false)
    end

    def self.chat(text, sender_id, channel = :local)
      Message.new(type: :chat_message, payload: { text: text, channel: channel },
                  sender_id: sender_id)
    end

    def self.player_move(pos, dir, player_id)
      Message.new(type: :player_move, payload: { pos: pos.to_a, dir: dir },
                  sender_id: player_id)
    end

    def self.object_update(object_id, changes)
      Message.new(type: :object_update, payload: { id: object_id.id, changes: changes })
    end

    def self.error(code, msg)
      Message.new(type: :error, payload: { code: code, message: msg })
    end

    def inspect
      "#<Message #{type_symbol.inspect} seq=#{@sequence}>"
    end
  end
end