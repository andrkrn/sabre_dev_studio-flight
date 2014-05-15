require File.expand_path('../airports_at_cities_lookup', __FILE__)
require File.expand_path('../city_pairs_lookup', __FILE__)
require File.expand_path('../destination_finder', __FILE__)
require File.expand_path('../fare_range', __FILE__)
require File.expand_path('../instaflights_search', __FILE__)
require File.expand_path('../lead_price_calendar', __FILE__)
require File.expand_path('../low_fare_forecast', __FILE__)
require File.expand_path('../multiairport_city_lookup', __FILE__)
require File.expand_path('../theme_airport_lookup', __FILE__)
require File.expand_path('../travel_seasonality', __FILE__)
require File.expand_path('../travel_theme_lookup', __FILE__)

module SabreDevStudio
  module Flight
    class Api
      ##
      # List of Air Shopping Themes
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/travel_theme_lookup
      #
      # ==== Example:
      #    air_shopping_themes = SabreDevStudio::Flight::Api.travel_theme_lookup
      def self.travel_theme_lookup
        endpoint = '/v1/shop/themes'
        SabreDevStudio::Flight::TravelThemeLookup.new(endpoint)
      end
      class << self; alias_method :air_shopping_themes, :travel_theme_lookup; end

      ##
      # Theme Airport Lookup
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/theme_airport_lookup
      #
      # ==== Example:
      #    airports = SabreDevStudio::Flight::Api.theme_airport_lookup('BEACH')
      def self.theme_airport_lookup(theme)
        endpoint = "/v1/shop/themes/#{theme}"
        SabreDevStudio::Flight::ThemeAirportLookup.new(endpoint)
      end

      ##
      # Shop for a destination (from a list of generalized destinations) given a date range
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/destination_finder
      #
      # Note: Timezones are specific to the departure and arrival airports (but not specified).
      #
      # ==== Example:
      #    options = {
      #      :origin        => 'LAS',
      #      :departuredate => '2014-06-22',
      #      :returndate    => '2014-06-23',
      #      :theme         => 'MOUNTAINS'
      #    }
      #    fares = SabreDevStudio::Flight::Api.destination_finder(options)
      def self.destination_finder(options)
        endpoint = '/v1/shop/flights/fares'
        SabreDevStudio::Flight::DestinationFinder.new(endpoint, options)
      end
      class << self; alias_method :destination_air_shop, :destination_finder; end

      ##
      # Future Dates Lead Fare Search, aka "Calendar Lead"
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/lead_price_calendar
      #
      # Note: Timezones are specific to the departure and arrival airports (but not specified).
      #
      # ==== Example:
      #    options = {
      #      :origin        => 'ATL',
      #      :destination   => 'LAS',
      #      :lengthofstay  => 5
      #    }
      #    fares = SabreDevStudio::Flight::Api.lead_price_calendar(options)
      def self.lead_price_calendar(options)
        endpoint = '/v1/shop/flights/fares'
        SabreDevStudio::Flight::LeadPriceCalendar.new(endpoint, options)
      end
      class << self; alias_method :future_dates_lead_fare_shop, :lead_price_calendar; end

      ##
      # Shop for a fare with an origin for a destination with departure and return dates
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/instaflights_search
      #
      # ==== Example:
      #    options = {
      #      :origin        => 'ATL',
      #      :destination   => 'LAS',
      #      :departuredate => '2014-06-22',
      #      :returndate    => '2014-06-23',
      #      :limit         => 10,
      #      :sortby        => 'totalfare',
      #      :order         => 'asc',
      #      :sortby2       => 'departuretime',
      #      :order2        => 'dsc'
      #    }
      #    itineraries = SabreDevStudio::Flight::Api.instaflights_search(options); nil
      def self.instaflights_search(options)
        endpoint = '/v1/shop/flights'
        SabreDevStudio::Flight::InstaflightsSearch.new(endpoint, options)
      end
      class << self; alias_method :single_date_air_shop, :instaflights_search; end

      ##
      # Low Fare Forecast
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/rest_apis/low_fare_forecast
      #
      # ==== Example:
      #    options = {
      #      :origin        => 'JFK',
      #      :destination   => 'LAX',
      #      :departuredate => '2014-10-01',
      #      :returndate    => '2014-10-05'
      #    }
      #    forecast = SabreDevStudio::Flight::Api.low_fare_forecast(options)
      def self.low_fare_forecast(options)
        endpoint = '/v1/forecast/flights/fares'
        SabreDevStudio::Flight::LowFareForecast.new(endpoint, options)
      end

      ##
      # Fare Range
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/fare_range
      #
      # ==== Example:
      #    options = {
      #      :origin                => 'JFK',
      #      :destination           => 'LAX',
      #      :earliestdeparturedate => '2014-06-01',
      #      :latestdeparturedate   => '2014-06-01',
      #      :lengthofstay          => 4
      #    }
      #    fare_range = SabreDevStudio::Flight::Api.fare_range(options)
      def self.fare_range(options)
        endpoint = '/v1/historical/flights/fares'
        SabreDevStudio::Flight::FareRange.new(endpoint, options)
      end

      ##
      # Travel Seasonality
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/travel_seasonality
      #
      # ==== Example:
      #    travel_seasonality = SabreDevStudio::Flight::Api.travel_seasonality('DFW')
      def self.travel_seasonality(destination)
        endpoint = "/v1/historical/flights/#{destination}/seasonality"
        SabreDevStudio::Flight::TravelSeasonality.new(endpoint)
      end

      ##
      # City Pairs Lookup
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/city_pairs_lookup
      #
      # ==== Example:
      #    options = {
      #      :origincountry       => 'US',
      #      :destinationcountry  => 'US'
      #    }
      #    city_pairs = SabreDevStudio::Flight::Api.city_pairs_lookup
      def self.city_pairs_lookup(options)
        endpoint = '/v1/lists/airports/supported/origins-destinations'
        SabreDevStudio::Flight::CityPairsLookup.new(endpoint, options)
      end

      ##
      # Multi-Airport City Lookup
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/multiairport_city_lookup
      #
      # ==== Example:
      #    options = { :country => 'US' }
      #    city_pairs = SabreDevStudio::Flight::Api.multiairport_city_lookup(options)
      def self.multiairport_city_lookup(options)
        endpoint = '/v1/lists/cities'
        SabreDevStudio::Flight::MultiairportCityLookup.new(endpoint, options)
      end

      ##
      # Airports At Cities Lookup
      #
      # ==== Documentation:
      # https://developer.sabre.com/docs/read/rest_apis/airports_at_cities_lookup
      #
      # ==== Example:
      #    options = { :city => 'NYC' }
      #    city_pairs = SabreDevStudio::Flight::Api.airports_at_cities_lookup(options)
      def self.airports_at_cities_lookup(options)
        endpoint = '/v1/lists/airports'
        SabreDevStudio::Flight::AirportsAtCitiesLookup.new(endpoint, options)
      end
    end
  end
end
