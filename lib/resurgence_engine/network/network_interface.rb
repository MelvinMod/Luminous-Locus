# ResurgenceEngine Network Interface
# Server/client communication layer
# 
# Abstract base for network implementations

module ResurgenceEngine
  class NetworkInterface
    attr_reader :mode, :connected, :tick_rate, :latency
    attr_reader :message_queue, :mutex, :clients, :max_clients

    # Create new network interface
    def initialize(mode: :single)
      valid_modes = [:server, :client, :single]
      unless valid_modes.include?(mode)
        raise ArgumentError, 'Invalid network mode'
      end

      @mode = mode
      @connected = false
      @tick_rate = 20
      @latency = 0
      @message_queue = []
      @mutex = Mutex.new
      @clients = []
      @max_clients = 64
      @running = false

      @on_message_handlers = {}
      @on_connect_handlers = []
      @on_disconnect_handlers = []
      @on_error_handlers = []
    end

    # Start network interface
    def start(host = '127.0.0.1', port = 0)
      raise NotImplementedError, 'Subclasses must implement #start'
    end

    # Stop network interface
    def stop
      @running = false
      @connected = false
    end

    # Send message
    def send(message, target = nil)
      raise NotImplementedError, 'Subclasses must implement #send'
    end

    # Broadcast message to all clients
    def broadcast(message, exclude = nil)
      @clients.each do |client|
        next if client == exclude
        send(message, client)
      end
    end

    # Receive next message
    def receive
      @mutex.synchronize do
        @message_queue.shift
      end
    end

    # Queue incoming message
    def queue_message(message)
      @mutex.synchronize do
        @message_queue << message
      end
    end

    # Process all queued messages
    def process_messages
      while (message = receive)
        handle_message(message)
      end
    end

    # Handle a message
    def handle_message(message)
      handler = @on_message_handlers[message.type_symbol]
      handler&.call(message)
    end

    # Register message handler
    def on_message(type, &block)
      @on_message_handlers[type] = block
    end

    # Register connect handler
    def on_connect(&block)
      @on_connect_handlers << block
    end

    # Register disconnect handler
    def on_disconnect(&block)
      @on_disconnect_handlers << block
    end

    # Register error handler
    def on_error(&block)
      @on_error_handlers << block
    end

    # Fire connect handlers
    def fire_connect(client)
      @on_connect_handlers.each { |h| h.call(client) }
    end

    # Fire disconnect handlers
    def fire_disconnect(client, reason)
      @on_disconnect_handlers.each { |h| h.call(client, reason) }
    end

    # Fire error handlers
    def fire_error(error)
      @on_error_handlers.each { |h| h.call(error) }
    end

    # Add client
    def add_client(client)
      return if @clients.size >= @max_clients
      @clients << client
    end

    # Remove client
    def remove_client(client)
      @clients.delete(client)
    end

    # Get client by ID
    def get_client(id)
      @clients.find { |c| c.id == id }
    end

    # Set tick rate
    def tick_rate=(rate)
      raise ArgumentError, 'Tick rate must be positive' unless rate.positive?
      @tick_rate = rate
    end

    # Calculate average latency
    def update_latency(latencies)
      return unless latencies.any?
      @latency = latencies.sum / latencies.size
    end

    # Check if connection is healthy
    def healthy?
      @connected && @latency < 1000
    end

    # Get connection quality
    def connection_quality
      case @latency
      when 0..50 then :excellent
      when 51..100 then :good
      when 101..200 then :fair
      when 201..500 then :poor
      else :dead
      end
    end

    # Network client wrapper
    class NetworkClient
      attr_reader :id, :address, :port, :bytes_received, :bytes_sent
      attr_accessor :authenticated, :username, :last_activity

      def initialize(id:, address:, port:)
        @id = id
        @address = address
        @port = port
        @authenticated = false
        @username = nil
        @last_activity = Time.now
        @bytes_received = 0
        @bytes_sent = 0
      end

      # Update activity timestamp
      def touch
        @last_activity = Time.now
      end

      # Record bytes received
      def record_received(bytes)
        @bytes_received += bytes
        touch
      end

      # Record bytes sent
      def record_sent(bytes)
        @bytes_sent += bytes
        touch
      end

      # Check if timed out
      def timed_out?(timeout = 30.0)
        Time.now - @last_activity > timeout
      end
    end
  end
end