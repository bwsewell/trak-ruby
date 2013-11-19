require 'net/http'
require 'json'

module Trak
  @api_base = 'api.trak.io'

  VERSION = '0.0.0'
  HEADERS = { 'Content-Type' => 'application/json' }

  class << self

    attr_accessor :api_key, :api_base, :distinct_id, :channel

    def initialize
      @http = Net::HTTP.new @api_base
    end

    def execute_request(url, data)
      response = @http.post(url, data, HEADERS)
      JSON.parse(response.body)
    end

    # Identify is how you send trak.io properties about a person like Email, Name, Account Type, Age, etc.
    #
    # @param distinct_id [String] A unique identifier for a user (visitor)
    # @param properties [Hash] A hash of properties about a person (example: `{:name => 'John Smith', :age => 40}`)
    # @return [Object]
    #
    def identify(distinct_id, properties)
      raise "distinct_id required" unless distinct_id
      raise "properties required" unless properties
      data = {
        :token => @api_key,
        :data => {
          :distinct_id => distinct_id,
          :properties => properties,
        },
      }.to_json

      # Set current session variable for distinct_id
      self.distinct_id = distinct_id

      execute_request('/v1/identify', data)
    end

    # Alias is how you set additional distinct ids for a person.
    # This is useful if you initially use trak.io's automatically generated
    # distinct id to identify or track a person but then they login or
    # register and you want to identify them by their email address or your
    # application's id for them. Doing this will allow you to identify users
    # across sessions and devices.
    #
    # @param distinct_id [String] The unique identifier of a user
    # @param aliases [String, Array] An array of distinct ids, you would like to add.
    # @return [Object]
    #
    def alias(distinct_id, aliases)
      raise "distinct_id required" unless distinct_id
      raise "aliases cannot be empty" unless aliases
      raise "aliases must be a String or an Array" unless aliases.kind_of?(Array) || aliases.kind_of?(String)
      data = {
        :token => @api_key,
        :data => {
          :distinct_id => distinct_id,
          :alias => aliases,
        },
      }.to_json

      # Set current session variable for distinct_id
      self.distinct_id = distinct_id

      execute_request('/v1/alias', data)
    end

    # Track is how you record the actions people perform. You can also record
    # properties specific to those actions. For a "Purchased shirt" event,
    # you might record properties like revenue, size, etc.
    #
    # @param event [String] The key for this event, this value will be standardized server side.
    # @param distinct_id [String] The distinct id of the person you wish to register this event against. When ommited the current session's distinct id is used.
    # @param channel [String] The channel this event occurred in. When ommitted the current session's channel is used.
    # @param properties [Hash] A set of key value properties that describe the event.
    # @return [Object]
    #
    def track(event, opts = {})
      defaults = {
        :distinct_id => self.distinct_id,
        :channel => self.channel,
        :properties => {},
      }
      opts = defaults.merge opts
      raise "event is required" unless event
      raise "properties must be a Hash" unless defaults[:properties].kind_of?(Hash)
      raise "No distinct_id is set.  Use 'identify' or 'alias' to set current session distinct_id" if opts[:distinct_id].nil?
      data = {
        :token => @api_key,
        :data => {
          :distinct_id => opts[:distinct_id],
          :event => event,
          :channel => opts[:channel],
          :properties => opts[:properties],
        },
      }.to_json

      # Set current session variable for distinct_id, channel
      self.distinct_id = opts[:distinct_id]

      execute_request('/v1/track', data)
    end

    # Annotate is a way of recording system wide events that affect everyone.
    # Annotations are similar to events except they are not associated with
    # any one person.
    #
    # @param event [String] The key for this annotation, this value will be standardized server side.
    # @param properties [Hash] A set of key value properties about the event for example if the event was an update you might include details about what was deployed or what version the system is now at.
    # @param channel [String] The channel this event occurred in.
    # @return [Object]
    #
    def annotate(event, opts = {})
      defaults = {
        :channel => channel,
        :properties => {},
      }
      opts = defaults.merge opts
      raise "event is required" unless event
      raise "properties must be a Hash" unless defaults[:properties].kind_of?(Hash)
      data = {
        :token => @api_key,
        :data => {
          :event => event,
          :channel => opts[:channel],
          :properties => opts[:properties],
        },
      }.to_json

      execute_request('/v1/annotate', data)
    end
  end
end