=begin

options = {
 :origin        => 'ATL',
 :destination   => 'LAS',
 :departuredate => '2014-06-01',
 :returndate    => '2014-06-05',
 :limit         => 300
}
itineraries = SabreDevStudio::Flight::Api.single_date_air_shop(options); nil
streamlined_itineraries = SabreDevStudio::Flight::Shop::StreamlinedItineraries.new(itineraries.response['PricedItineraries']); nil

-- or --

require 'json'
itineraries = JSON.parse(File.read('./test/fixtures/single_date_air_shop.json')); nil
streamlined_itineraries = SabreDevStudio::Flight::Shop::StreamlinedItineraries.new(itineraries['PricedItineraries']); nil
pp streamlined_itineraries; nil

=end

# require 'digest'
module SabreDevStudio
  module Flight
    module Shop
      class StreamlinedItineraries
        attr_reader :flights, :outbounds, :min_price, :max_price,
                    :min_outbound_duration, :max_outbound_duration, :airline_codes

        def initialize(itineraries)
          @flights = []
          @outbounds = []
          @min_price = @max_price = nil
          @min_outbound_duration = @max_outbound_duration = nil
          outbound_flights = Hash.new
          outbound_flight = nil

          itineraries.each do |itin|
            segments = itin['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption']
            amount = itin['AirItineraryPricingInfo']['ItinTotalFare']['TotalFare']['Amount'].to_f
            segments.each_with_index.each do |segment, idx|
              direction = idx % 2 == 0 ? 'outbound' : 'inbound'
              flight = Flight.new(segment['FlightSegment'], direction, segment['ElapsedTime'])
              @flights << flight.to_hash

              set_price(amount)
              if flight.direction == 'outbound'
                set_duration(flight.duration)
                outbound_flight = flight
                outbound_flights[outbound_flight.sha] ||= OutboundFlight.new(flight, amount)
              else
                outbound_flights[outbound_flight.sha].add_inbound_flight(flight, amount)
              end

              if segment['FlightSegment'].is_a?(Array)
                segment['FlightSegment'].each_with_index do |flight_segment, idx|
                  # next if idx > 0
                  connection = Flight.new(flight_segment, 'connecting', segment['ElapsedTime'])
                  next if connection.sha == flight.sha
                  @flights << connection.to_hash
                  flight.add_connecting_flight(connection)
                end
              end
            end
          end

          @airline_codes = @flights.map { |f| f[:airlines] }.flatten.uniq.sort
          @flights.uniq!
          @outbounds = outbound_flights.values.map(&:to_hash)
        end

        def set_price(fare)
          @min_price = fare if @min_price.nil? || fare < @min_price
          @max_price = fare if @max_price.nil? || fare > @max_price
        end
        def set_duration(duration)
          @min_outbound_duration = duration if @min_outbound_duration.nil? || duration < @min_outbound_duration
          @max_outbound_duration = duration if @max_outbound_duration.nil? || duration > @max_outbound_duration
        end
      end

      class Flight
        attr_reader :direction, :airlines, :duration, :flight_number,
                    :departure_airport, :arrival_airport,
                    :stops, :departure_time, :arrival_time, :connections

        def initialize(flight_segment, direction, duration)
          @airlines = []
          @stops = []
          @connections = []
          @direction = direction
          if direction == 'connecting'
            @duration = flight_segment['ElapsedTime']
          else
            @duration = duration
          end
          parse_data(flight_segment)
        end

        def sha
          str = "#{@airlines.first}_#{@flight_number}_#{@departure_airport}_#{@departure_time}"
          # Digest::SHA1.hexdigest(str)
          str
        end

        def to_hash
          {
            uid: sha,
            direction: @direction,
            airlines: airlines.uniq,
            duration: minutes_to_time(duration),
            departureAirport: departure_airport,
            arrivalAirport: arrival_airport,
            stops: stops,
            connections: connections,
            departureTime: reformat_date_time(departure_time),
            arrivalTime: reformat_date_time(arrival_time)
          }
        end

        def add_connecting_flight(flight)
          @connections << flight.sha
        end

        private

        def parse_data(flight_segment)
          if flight_segment.is_a?(Array)
            flight_segment.each_with_index do |segment, idx|
              if idx == 0
                @departure_airport = segment['DepartureAirport']['LocationCode']
                @departure_time = segment['DepartureDateTime']
                @stops << segment['ArrivalAirport']['LocationCode']
                @airlines << segment['MarketingAirline']['Code']
                @flight_number = segment['FlightNumber']
              elsif idx == flight_segment.length - 1
                @arrival_airport = segment['ArrivalAirport']['LocationCode']
                @arrival_time = segment['ArrivalDateTime']
                @airlines << segment['MarketingAirline']['Code']
              else
                @stops << segment['ArrivalAirport']['LocationCode']
                @airlines << segment['MarketingAirline']['Code']
              end
            end
          else
            @departure_airport = flight_segment['DepartureAirport']['LocationCode']
            @arrival_airport = flight_segment['ArrivalAirport']['LocationCode']
            @departure_time = flight_segment['DepartureDateTime']
            @arrival_time = flight_segment['ArrivalDateTime']
            @airlines << flight_segment['MarketingAirline']['Code']
            @flight_number = flight_segment['FlightNumber']
          end
        end

        def minutes_to_time(minutes)
          minutes = minutes.to_i
          {
            hour: minutes / 60,
            minutes: minutes % 60,
            raw: minutes
          }
        end

        # "2013-06-01T09:56:00" --> "9:56 am"
        # "2013-06-01T19:06:00" --> "7:06 pm"
        def reformat_date_time(datetime)
          datetime =~ /\d+-\d+-\d+T(\d+):(\d+):\d+/
          hour, minute = $1.to_i, $2.to_i
          am_pm = hour < 12 ? 'am' : 'pm'

          hour = hour % 12
          hour = hour == 0 ? 12 : hour
          minute = sprintf("%02d", minute)
          "#{hour}:#{minute} #{am_pm}"
        end
      end

      class OutboundFlight
        attr_reader :flight_uuid, :inbounds, :min_price, :max_price,
                    :duration, :min_inbound_duration, :max_inbound_duration

        def initialize(flight, price)
          @flight_uuid = flight.sha
          @min_price = @max_price = price
          @inbounds = []
          @duration = flight.duration
          @min_inbound_duration = @max_inbound_duration = nil
        end

        def add_inbound_flight(flight, price)
          set_min_price(price)
          set_inbound_duration(flight.duration)
          @inbounds << {
            flight_uuid: flight.sha,
            price: price
          }
        end

        def to_hash
          {
            flight_uuid: flight_uuid,
            min_price: min_price,
            max_price: max_price,
            duration: duration,
            min_inbound_duration: min_inbound_duration,
            max_inbound_duration: max_inbound_duration,
            inbounds: inbounds.uniq
          }
        end

        private

        def set_min_price(price)
          @min_price = price if price < @min_price
          @max_price = price if price > @max_price
        end

        def set_inbound_duration(duration)
          @min_inbound_duration = duration if @min_inbound_duration.nil? || duration < @min_inbound_duration
          @max_inbound_duration = duration if @max_inbound_duration.nil? || duration > @max_inbound_duration
        end
      end
    end
  end
end
