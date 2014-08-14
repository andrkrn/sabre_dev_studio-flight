# SabreDevStudio::Flight

Access the Travel Platform Services Flight API

[![Build Status](https://travis-ci.org/SabreDevStudio/sabre_dev_studio-flight.svg?branch=master)](https://travis-ci.org/SabreDevStudio/sabre_dev_studio-flight)

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
      c.client_id     = 'V1:1234:ABCD:XYZ'
      c.client_secret = 'SeKr1T'
      c.uri           = 'https://api.test.sabre.com'
    end
    options = {
      :origin        => 'DFW',
      :departuredate => '2014-08-22',
      :returndate    => '2014-08-23',
      :theme         => 'BEACH'
    }
    fares = SabreDevStudio::Flight::Api.destination_air_shop(options)
    fare_info = fares.fare_info

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See LICENSE.txt

## Disclaimer of Warranty and Limitation of Liability

This software and any compiled programs created using this software are furnished “as is” without warranty of any kind, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. No oral or written information or advice given by Sabre, its agents or employees shall create a warranty or in any way increase the scope of this warranty, and you may not rely on any such information or advice.
Sabre does not warrant, guarantee, or make any representations regarding the use, or the results of the use, of this software, compiled programs created using this software, or written materials in terms of correctness, accuracy, reliability, currentness, or otherwise. The entire risk as to the results and performance of this software and any compiled applications created using this software is assumed by you. Neither Sabre nor anyone else who has been involved in the creation, production or delivery of this software shall be liable for any direct, indirect, consequential, or incidental damages (including damages for loss of business profits, business interruption, loss of business information, and the like) arising out of the use of or inability to use such product even if Sabre has been advised of the possibility of such damages.
