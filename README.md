# trak.io Ruby API Wrapper

[![Gem Version](https://badge.fury.io/rb/trak-ruby.png)](http://badge.fury.io/rb/trak-ruby)

This is the gem that allows Ruby bindings for the trak.io V1 API.

## Rails Installation

Add this line to your application's Gemfile:

    gem 'trak-ruby'

Create an initilizer `config/initializers/trak.rb` with the following code:

```ruby
Trak.api_key = "YOUR API KEY HERE"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install 'trak-ruby'

===

## API Methods

### Identify

```ruby
Trak.identify(distinct_id, properties)
```

Identify is how you send trak.io properties about a person like Email, Name, Account Type, Age, etc.

Learn more about implementation of `identify` on trak.io's [API documentation](http://docs.trak.io/identify.html)

```ruby
Trak.identify(1, {:name => 'John Smith', :email => 'john@test.com'})
```

The `identify` method will set the class variable `@distinct_id` to whatever you pass as your first parameter.

### Alias

```ruby
Track.alias(distinct_id, aliases)
```

Alias is how you set additional distinct ids for a person. This is useful if you initially use trak.io's automatically generated distinct id to identify or track a person but then they login or register and you want to identify them by their email address or your application's id for them. Doing this will allow you to identify users across sessions and devices. But of course you want to tie their activity before and after they logged in together, Trak.alias() will do this for you.

Learn more about implementation of `alias` on trak.io's [API documentation](http://docs.trak.io/alias.html)

```ruby
# Pass a string to add a new alias for a person with distinct_id = 1
Trak.alias(1, 'Johnny')

# Pass an array of aliases for a person with distinct_id = 1
Trak.alias(1, ['Johnny', 'john'])
```

The `alias` method will set the class variable `@distinct_id` to whatever you pass as your first parameter.

### Track

```ruby
Trak.track(event, opts = {})
```

Track is how you record the actions people perform. You can also record properties specific to those actions. For a "Purchased shirt" event, you might record properties like revenue, size, etc.

Learn more about implementation of `track` on trak.io's [API documentation](http://docs.trak.io/track.html)

```ruby
# Log the event 'played video'
Trak.track('played video')

# Log the event 'played video' for a person with distinct_id = 1
Trak.track('played video', {:distinct_id => 1})

# Log the event 'played video' on the 'Blog' channel
Trak.track('played video', {:channel => 'Blog'})

# Log an event with custom properties attached:
# Log the event 'search' on the 'Web site' channel along with
# any related properties you wish to track
Trak.track('search', {
  :channel => 'Web site',
  :properties => {
    :search_term => 'iPad Air',
    :search_category => 'Electronics',
  },
})
```

The `track` method will set the class variable `@distinct_id` if you pass it a distinct_id in the `opts` hash.

### Page View

```ruby
Trak.page_view(url, page_title, opts = {})
```

Page view is just a wrapper for: `Trak.track('Page View')`

Learn more about implementation of `page_view` on trak.io's [API documentation](http://docs.trak.io/page_view.html)

```ruby
# Log a user visiting the settings page
Trak.page_view('http://mysite.com/settings', 'Settings')
```

The `page_view` method will set the class variable `@distinct_id` if you pass it a distinct_id in the `opts` hash.

### Annotate

```ruby
Trak.annotate(event, opts = {})
```

Annotate is a way of recording system wide events that affect everyone. Annotations are similar to events except they are not associated with any one person.

Learn more about implementation of `annotate` on trak.io's [API documentation](http://docs.trak.io/annotate.html)

```ruby
# Annotate a deploy
Trak.annotate('Deployed update')

# Annotate a deploy for a specific channel
Trak.annotate('Deployed update', {:channel => 'Web site'})
```

### Distinct ID

```ruby
# Returns the current distinct id
Trak.distinct_id

# Sets the current distinct_id
Trak.distinct_id = 1
```

### Channel

```ruby
# Returns the current channel
Trak.channel

# Sets the current channel
Trak.channel = 'Web site'
```

===

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
