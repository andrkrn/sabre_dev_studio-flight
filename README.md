# SabreDevStudio::Flight

Access the Travel Platform Services Flight API

## Installation

Add this line to your application's Gemfile:

    gem 'sabre_dev_studio-flight'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sabre_dev_studio-flight

## Usage
Once you've registered for your account at http://developer.sabre.com, grab your credentials and plug them into the `configure` block.

    irb -r ./lib/sabre_dev_studio-flight.rb

    SabreDevStudio.configure do |c|
      c.user     = 'USER'
      c.group    = 'GROUP'
      c.domain   = 'DOMAIN'
      c.password = 'PASSWORD'
      c.uri      = 'https://api.test.sabre.com'
    end
    options = {
      :origin        => 'LAS',
      :departuredate => '2014-06-22',
      :returndate    => '2014-06-23',
      :theme         => 'MOUNTAINS'
    }
    fares = SabreDevStudio::Flight::Api.destination_air_shop(options)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
