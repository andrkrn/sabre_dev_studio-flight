require File.expand_path("../test_helper", __FILE__)

class ApiTests < Test::Unit::TestCase
  def setup
    SabreDevStudio.configure do |c|
      c.client_id     = 'V1:USER:GROUP:DOMAIN'
      c.client_secret = 'PASSWORD'
      c.uri           = 'https://api.test.sabre.com'
    end
    stub_request(:post, "https://VjE6VVNFUjpHUk9VUDpET01BSU4%3D:UEFTU1dPUkQ%3D@api.test.sabre.com/v1/auth/token").
      to_return(:status => 200, :body =>"{\"access_token\":\"Shared/IDL:IceSess\\\\/SessMgr:1\\\\.0.IDL/Common/!ICESMS\\\\/ACPCRTD!ICESMSLB\\\\/CRT.LB!-3801964284027024638!507667!0!F557CBE649675!E2E-1\",\"token_type\":\"bearer\",\"expires_in\":1800}")
  end

  def test_air_shopping_theme_api
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/shop/themes").
      to_return(json_response('air_shopping_themes.json'))
    air_shopping_themes = SabreDevStudio::Flight::Api.air_shopping_themes
    assert_equal 11, air_shopping_themes.response['Themes'].count
    assert_equal 'BEACH', air_shopping_themes.response['Themes'].first['Theme']
    assert_equal 'BEACH', air_shopping_themes.themes.first.theme
  end

  def test_theme_airport_lookup_api
    theme = 'DISNEY'
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/shop/themes/#{theme}").
      to_return(json_response('theme_airport_lookup.json'))
    airports = SabreDevStudio::Flight::Api.theme_airport_lookup(theme)
    assert_equal 7, airports.destinations.count
    assert_equal 'BUR', airports.destinations.first.destination
  end

  def test_destination_air_shop_api
    options = {
      :origin        => 'LAS',
      :lengthofstay  => 1,
      :theme         => 'MOUNTAINS'
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/shop/flights/fares?#{uri.query}").
      to_return(json_response('destination_air_shop.json'))
    fares = SabreDevStudio::Flight::Api.destination_air_shop(options)
    assert_equal options[:origin], fares.origin_location
    assert_equal 31, fares.fare_info.count
    assert_equal 158, fares.fare_info.first.lowest_fare
    date = SabreDevStudio::Helpers::DateExtensions.make_date(fares.fare_info.first.departure_date_time)
    assert_equal 4, date.month
    assert_equal options[:origin], fares.response['OriginLocation']
    assert_equal 158, fares.response['FareInfo'].first['LowestFare']
  end

  def test_future_dates_lead_fare_shop_api
    options = {
      :origin        => 'JFK',
      :destination   => 'LAX',
      :lengthofstay  => 5
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/shop/flights/fares?#{uri.query}").
      to_return(json_response('future_dates_lead_fare_shop.json'))
    fares = SabreDevStudio::Flight::Api.future_dates_lead_fare_shop(options)
    assert_equal options[:origin], fares.origin_location
    assert_equal 193, fares.fare_info.count
    assert_equal 792, fares.fare_info.first.lowest_fare
    assert_equal options[:origin], fares.response['OriginLocation']
    assert_equal 792, fares.response['FareInfo'].first['LowestFare']
  end

  def test_single_date_air_shop_api
    options = {
      :origin                => 'JFK',
      :destination           => 'LAX',
      :departuredate         => '2014-10-01',
      :returndate            => '2014-10-05',
      :onlineitinerariesonly => 'N',
      :limit                 => 1,
      :offset                => 1,
      :sortby                => 'totalfare',
      :order                 => 'asc',
      :sortby2               => 'departuretime',
      :order2                => 'dsc'
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/shop/flights?#{uri.query}").
      to_return(json_response('single_date_air_shop.json'))
    fares = SabreDevStudio::Flight::Api.single_date_air_shop(options)
    assert_equal options[:origin], fares.origin_location
    assert_equal 387.0, fares.priced_itineraries.first.air_itinerary_pricing_info.itin_total_fare.total_fare.amount
    assert_equal options[:origin], fares.response['OriginLocation']
    assert_equal 387, fares.response['PricedItineraries'].first['AirItineraryPricingInfo']['ItinTotalFare']['TotalFare']['Amount']
  end

  def test_low_fare_forecast_api
    options = {
      :origin        => 'JFK',
      :destination   => 'LAX',
      :departuredate => '2014-10-01',
      :returndate    => '2014-10-05'
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/forecast/flights/fares?#{uri.query}").
      to_return(json_response('low_fare_forecast.json'))
    forecast = SabreDevStudio::Flight::Api.low_fare_forecast(options)
    assert_equal options[:origin], forecast.origin_location
    assert_equal options[:origin], forecast.response['OriginLocation']
    assert_equal options[:destination], forecast.response['DestinationLocation']
    assert_equal 387.0, forecast.response['LowestFare']
  end

  def test_fare_range_api
    options = {
      :origin                => 'JFK',
      :destination           => 'LAX',
      :earliestdeparturedate => '2014-06-01',
      :latestdeparturedate   => '2014-06-01',
      :lengthofstay          => 4
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/historical/flights/fares?#{uri.query}").
      to_return(json_response('fare_range.json'))
    fare_range = SabreDevStudio::Flight::Api.fare_range(options)
    assert_equal options[:origin], fare_range.origin_location
    assert_equal options[:destination], fare_range.destination_location
    assert_equal 1, fare_range.fare_data.count
    assert_equal options[:origin], fare_range.response['OriginLocation']
    assert_equal options[:destination], fare_range.response['DestinationLocation']
    assert_equal 1, fare_range.response['FareData'].count
  end

  def test_travel_seasonality_api
    destination = 'DFW'
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/historical/flights/#{destination}/seasonality").
      to_return(json_response('travel_seasonality.json'))
    travel_seasonality = SabreDevStudio::Flight::Api.travel_seasonality(destination)
    assert_equal destination, travel_seasonality.destination_location
    assert_equal 52, travel_seasonality.seasonality.count
    assert_equal 1, travel_seasonality.seasonality.first.year_week_number
    assert_equal destination, travel_seasonality.response['DestinationLocation']
    assert_equal 52, travel_seasonality.response['Seasonality'].count
    assert_equal 1, travel_seasonality.response['Seasonality'].first['YearWeekNumber']
    assert_equal 'Low', travel_seasonality.response['Seasonality'].first['SeasonalityIndicator']
  end

  def test_city_pairs_lookup_api
    options = {
      :origincountry       => 'US',
      :destinationcountry  => 'US'
    }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/lists/airports/supported/origins-destinations?#{uri.query}").
      to_return(json_response('city_pairs.json'))
    city_pairs = SabreDevStudio::Flight::Api.city_pairs_lookup(options)
    assert_equal 982, city_pairs.origin_destination_locations.count
    assert_equal 'DEN', city_pairs.origin_destination_locations.first.origin_location.airport_code
    assert_equal 'ABQ', city_pairs.origin_destination_locations.first.destination_location.airport_code
    assert_equal 982, city_pairs.response['OriginDestinationLocations'].count
    assert_equal 'DEN', city_pairs.response['OriginDestinationLocations'].first['OriginLocation']['AirportCode']
    assert_equal 'ABQ', city_pairs.response['OriginDestinationLocations'].first['DestinationLocation']['AirportCode']
  end

  def test_multiairport_city_lookup_api
    options = { :country => 'US' }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/lists/cities?#{uri.query}").
      to_return(json_response('multiairport_city_lookup.json'))
    city_lookup = SabreDevStudio::Flight::Api.multiairport_city_lookup(options)
    assert_equal 15, city_lookup.cities.count
    assert_equal 'WAS', city_lookup.cities.last.code
    assert_equal 15, city_lookup.response['Cities'].count
    assert_equal 'WAS', city_lookup.response['Cities'].last['code']
  end

  def test_airports_at_cities_lookup_api
    options = { :city => 'QDF' }
    uri = Addressable::URI.new
    uri.query_values = options
    stub_request(:get, "#{SabreDevStudio.configuration.uri}/v1/lists/airports?#{uri.query}").
      to_return(json_response('airports_at_cities_lookup.json'))
    airports = SabreDevStudio::Flight::Api.airports_at_cities_lookup(options)
    assert_equal 3, airports.airports.count
    assert_equal 'EWR', airports.airports.first.code
    assert_equal 'NEWARK', airports.airports.first.name
    assert_equal 3, airports.response['Airports'].count
    assert_equal 'EWR', airports.response['Airports'].first['code']
  end
end
