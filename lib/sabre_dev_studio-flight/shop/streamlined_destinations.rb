=begin

   options = {
     :origin        => 'LAS',
     :departuredate => '2014-06-01',
     :returndate    => '2014-06-05'
   }
   destinations = SabreDevStudio::Flight::Api.destination_air_shop(options); nil
   streamlined_destinations = SabreDevStudio::Flight::Shop::StreamlinedDestinations.new(destinations.response); nil
   pp streamlined_destinations; nil

=end

module SabreDevStudio
  module Flight
    module Shop
      class StreamlinedDestinations
        attr_reader :destinations

        def initialize(bulky_destinations)
          @destinations = Hash.new
          streamline(bulky_destinations['FareInfo'])
        end

        private

        def streamline(bulky_destinations)
          destinations = {}
          bulky_destinations.each do |dest|
            destinations[dest['DestinationLocation']] = dest['LowestFare'].ceil
          end
          arr = destinations.sort_by {|k,v| v}
          @destinations = Hash[*arr.flatten]
        end
      end
    end
  end
end
