require 'net/http'
require 'json'

class Trak

  VERSION = '0.0.3'
  HEADERS = { 'Content-Type' => 'application/json' }

  attr_accessor :distinct_id, :channel

  def initialize(api_key = nil)
    raise "api_key required" unless api_key || defined? API_KEY
    @api_key = api_key ? api_key : API_KEY
    api_base = 'api.trak.io'
    @http = Net::HTTP.new api_base
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
  def identify(distinct_id, properties = {})
    raise "distinct_id required" unless distinct_id
    raise "properties must be a Hash" unless aliases.kind_of?(Hash)
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
  # @param opts [Hash] options to pass to track call (distinct_id [String], channel [String], properties [Hash])
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

    # Set current session variable for distinct_id
    self.distinct_id = opts[:distinct_id]

    execute_request('/v1/track', data)
  end

  # Page view is just a wrapper for: Trak.track('Page view')
  #
  # @param url [String] The key for this event, this value will be standardized server side.
  # @param page_title [String] The distinct id of the person you wish to register this event against. When ommited the current session's distinct id is used.
  # @param opts [Hash] options to pass to track call (distinct_id [String], channel [String])
  # @return [Object]
  #
  def page_view(url, page_title, opts = {})
    defaults = {
      :event => 'Page view',
      :distinct_id => self.distinct_id,
      :channel => self.channel,
      :properties => {
        :url => url,
        :page_title => page_title,
      },
    }
    opts = defaults.merge opts
    raise "url" unless url
    raise "page_title" unless page_title
    raise "properties must be a Hash" unless defaults[:properties].kind_of?(Hash)
    raise "No distinct_id is set.  Use 'identify' or 'alias' to set current session distinct_id" if opts[:distinct_id].nil?
    data = {
      :token => @api_key,
      :data => {
        :distinct_id => opts[:distinct_id],
        :event => opts[:event],
        :channel => opts[:channel],
        :properties => opts[:properties],
      },
    }.to_json

    # Set current session variable for distinct_id
    self.distinct_id = opts[:distinct_id]

    execute_request('/v1/track', data)
  end

  # Annotate is a way of recording system wide events that affect everyone.
  # Annotations are similar to events except they are not associated with
  # any one person.
  #
  # @param event [String] The key for this annotation, this value will be standardized server side.
  # @param opts [Hash] options to pass to annotate call (channel [String], properties [Hash])
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