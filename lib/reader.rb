require 'rss'
require 'open-uri'

class Reader
  class << self
    def from_console
      url = process_input
      until url.empty? do
        read_rss(url)
        url = process_input
      end
    rescue SocketError 
      'There was a problem opening the URL'
    rescue Errno::ENOENT
      'The url was treated as a directory'
    rescue RSS::NotWellFormedError
      'RSS was not well formed'
    end

    private

    def process_input
      pp '--------------------'
      console_message
      handle_input
    end

    def handle_input
      gets.chomp
    end

    def console_message
      pp 'Introduce a RSS URL (or return to exit)'
    end

    def read_rss(url)
      URI.open(url) {|rss| parse_rss(rss)}
    end
  
    def parse_rss(rss)
      feed = RSS::Parser.parse(rss)
      iterate_result(feed)
    end

    def iterate_result(feed)
      return unless feed
      feed.items.each do |item|
        pp "-- Title: #{item.title} --"
        pp "-- Link: #{item.link} --"
        pp "-- Description: #{item.description} --"
      end
    end
  end
end