class Evey::Dispatcher
  def self.enable!
    @disabled = false
  end

  def self.disable!
    @disabled = true
  end

  def self.enabled?
    @disabled != true
  end

  def self.configure
    if block_given?
      @rules = nil
      yield self
    end
  end

  # Register Reactors to Events.
  # * Reactors registered with `sync` will be triggered synchronously
  # * Reactors registered with `async` will be triggered asynchronously via a Sidekiq Job
  #
  # Example:
  #
  #   on BaseEvent, sync: LogEvent, async: TrackEvent
  #   on PledgeCancelled, PaymentFailed, async: [NotifyAdmin, CreateTask]
  #   on [PledgeCancelled, PaymentFailed], async: [NotifyAdmin, CreateTask]
  #
  def self.on(*events, sync: [], async: [])
    rules.register(events: events.flatten, sync: Array(sync), async: Array(async))
  end

  # Dispatches events to matching Reactors once.
  # Called by all events after they are created.
  def self.dispatch(event)
    return unless enabled?

    reactors = rules.for(event)
    reactors.sync.each { |reactor| reactor.call(event) }
    reactors.async.each { |reactor| Evey::ReactorJob.perform_later(event, reactor.to_s) }
  end

  def self.rules
    @rules ||= RuleSet.new
  end

  class RuleSet
    def initialize
      @rules ||= Hash.new { |h, k| h[k] = ReactorSet.new }
    end

    # Register events with their sync and async Reactors
    def register(events:, sync:, async:)
      events.each do |event|
        @rules[event].add_sync sync
        @rules[event].add_async async
      end
    end

    # Return a ReactorSet containing all Reactors matching an Event
    def for(event)
      reactors = ReactorSet.new

      @rules.each do |event_class, rule|
        if event.class == event_class
          reactors.add_sync rule.sync
          reactors.add_async rule.async
        end
      end

      reactors
    end
  end

  # Contains sync and async reactors. Used to:
  # * store reactors via Rules#register
  # * return a set of matching reactors with Rules#for
  class ReactorSet
    attr_reader :sync, :async

    def initialize
      @sync = Set.new
      @async = Set.new
    end

    def add_sync(reactors)
      @sync += reactors
    end

    def add_async(reactors)
      @async += reactors
    end
  end
end
