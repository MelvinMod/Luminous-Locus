# frozen_string_literal: true

module ResurgenceEngine
  module Network
    # Network message types
    MSG_POSITION = 1
    MSG_CHAT = 2
    MSG_ACTION = 3
    MSG_PING = 4
    MSG_PONG = 5
    MSG_CONNECT = 6
    MSG_DISCONNECT = 7

    # Client connection states
    STATE_DISCONNECTED = 0
    STATE_CONNECTING = 1
    STATE_CONNECTED = 2
    STATE_AUTHENTICATED = 3

    # TCP network implementation
    class TCPInterface < NetworkInterface
      attr_reader :socket, :server_socket

      def initialize(mode: :single)
        super(mode: mode)
        @socket = nil
        @server_socket = nil
      end

      def start(host = '127.0.0.1', port = 1111)
        if @mode == :server
          start_server(host, port)
        elsif @mode == :client
          start_client(host, port)
        end
      end

      def start_server(host, port)
        @server_socket = TCPServer.new(host, port)
        @connected = true
        @running = true
        puts "Server started on #{host}:#{port}"
        accept_loop
      end

      def start_client(host, port)
        @socket = TCPSocket.new(host, port)
        @connected = true
        @running = true
        puts "Connected to #{host}:#{port}"
        receive_loop
      end

      def accept_loop
        loop do
          break unless @running
          client = @server_socket&.accept
          next unless client

          add_client(client)
          client_handler = Thread.new(client) { |c| handle_client(c) }
          client_handler.abort_on_exception = true
        end
      end

      def receive_loop
        loop do
          break unless @running
          begin
            data = @socket&.read(1024)
            break unless data && !data.empty?

            message = Message.deserialize(data)
            queue_message(message)
          rescue => e
            puts "Connection lost: #{e.message}"
            break
          end
        end
      end

      def handle_client(client)
        loop do
          break unless @running
          begin
            data = client.read(1024)
            break unless data && !data.empty?

            message = Message.deserialize(data)
            handle_message(message)
          rescue => e
            puts "Client error: #{e.message}"
            break
          end
        end
        remove_client(client)
      end

      def send(message, target = nil)
        data = message.serialize
        if @mode == :server && target
          target.write(data)
        elsif @socket
          @socket.write(data)
        end
      end

      def stop
        @running = false
        @socket&.close
        @server_socket&.close
        @connected = false
      end
    end

    # UDP network implementation
    class UDPInterface < NetworkInterface
      attr_reader :socket

      def initialize(mode: :single)
        super(mode: mode)
        @socket = nil
        @remote_addr = nil
      end

      def start(host = '127.0.0.1', port = 1111)
        @socket = UDPSocket.new
        @socket.bind(host, port)
        @connected = true
        @running = true
        puts "UDP interface started on #{host}:#{port}"
        receive_loop
      end

      def receive_loop
        loop do
          break unless @running
          data, @remote_addr = @socket.recvfrom(1024)
          message = Message.deserialize(data)
          queue_message(message)
        end
      end

      def send(message, target = nil)
        data = message.serialize
        if target
          @socket.send(data, 0, target[:host], target[:port])
        elsif @remote_addr
          @socket.send(data, 0, @remote_addr[2], @remote_addr[1])
        end
      end

      def broadcast(message)
        @clients.each do |client|
          send(message, client)
        end
      end

      def stop
        @running = false
        @socket&.close
        @connected = false
      end
    end

    # Network message class
    class Message
      attr_accessor :type, :data

      def initialize(type: 0, data: {})
        @type = type
        @data = data
      end

      def type_symbol
        case @type
        when MSG_POSITION then :position
        when MSG_CHAT then :chat
        when MSG_ACTION then :action
        when MSG_PING then :ping
        when MSG_PONG then :pong
        when MSG_CONNECT then :connect
        when MSG_DISCONNECT then :disconnect
        else :unknown
        end
      end

      def serialize
        { type: @type, data: @data }.to_json
      end

      def self.deserialize(json)
        parsed = JSON.parse(json)
        new(type: parsed['type'], data: parsed['data'])
      end
    end
  end
end
