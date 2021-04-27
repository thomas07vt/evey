class Evey::Event < ActiveRecord::Base
  include Kix::Serializable

  belongs_to :user, optional: true

  before_create :apply_and_persist
  after_create_commit :dispatch

  attribute :aggregates, Evey::Types::Association.new
  attribute :associations, Evey::Types::Association.new

  class << self
    def registered_events
      @registered_events ||= {}
    end

    def inherited(klass)
      super
      ::Evey::Event.registered_events[klass.event_name] = klass
      klass.request_hook(&@request_hook) if @request_hook
    end

    def aggregates(*ags)
      @aggregates ||= []

      ags.map(&:to_s).each do |ag|
        next if @aggregates.include?(ag)

        @aggregates << ag

        define_method ag do
          self.aggregates ||= {}
          self.aggregates[ag]
        end

        define_method "#{ag}=" do |arg|
          self.aggregates ||= {}
          self.aggregates[ag] = arg
        end
      end

      @aggregates
    end
    alias_method :aggregate, :aggregates

    def associations(*assoces)
      @associations ||= []

      assoces.map(&:to_s).each do |assoc|
        next if @associations.include?(assoc)

        @associations << assoc

        define_method assoc do
          self.associations ||= {}
          self.associations[assoc]
        end

        define_method "#{assoc}=" do |arg|
          self.associations ||= {}
          self.associations[assoc] = arg
        end
      end

      @associations
    end
    alias_method :association, :associations

    def data_attributes(*attrs)
      @data_attributes ||= []

      attrs.map(&:to_s).each do |attr|
        @data_attributes << attr unless @data_attributes.include?(attr)

        define_method attr do
          self.data ||= {}
          self.data[attr]
        end

        define_method "#{attr}=" do |arg|
          self.data ||= {}
          self.data[attr] = arg
        end

        define_method "#{attr}_was_set?" do
          self.data ||= {}
          self.data.key?(attr)
        end
      end

      @data_attributes
    end

    def request_hook(&block)
      @request_hook = block if block.present?
      @request_hook
    end

    # Underscored class name by default. ex: "post/updated"
    # Used when sending events to the data pipeline
    def event_name
      name.underscore
    end
  end

  delegate :event_name, to: :class

  after_initialize do
    self.data ||= {}
    self.associations ||= {}
    self.aggregates ||= {}
    self.metadata ||= {}
    self.type ||= self.class.name
  end

  def apply
  end

  def request_hook
    self.class.request_hook
  end

  def errors_as_json
    return {} if errors.blank?

    errors.as_json.merge(aggregate_errors_as_json)
  end

  private

  def apply_and_persist
    self.uuid ||= SecureRandom.uuid

    aggregates.values.map(&:lock!)
    apply
    aggregates.map do |name, aggregate|
      errors.add(name, 'is invalid') unless aggregate.save
    end

    throw :abort if errors.any?
  end

  def dispatch
    Evey::Dispatcher.dispatch(self)
  end

  def aggregate_errors_as_json
    aggregates.each_with_object({}) do |array, hash|
      name, aggregate = array
      hash[name.to_sym] = aggregate.errors.as_json if aggregate.errors.present?
    end
  end
end
