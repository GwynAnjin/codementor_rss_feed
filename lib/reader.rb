require 'rss'
require 'open-uri'

class Reader
  class << self
    def from_file(path)
      return 'File does not exist' unless File.exist?(path)
      File.open(path, 'r') do |f|
        f.each do |line|
          read_rss(line.chomp)
        end
      end
      count_processed_lines(path)
    end
  
    def from_console
      url = process_input
      until url.empty? do
        read_rss(url)
        url = process_input
      end
    rescue OpenURI::HTTPError 
      'There was a problem opening the URL'
    rescue Errno::ENOENT
      'The url was treated as a directory'
    rescue RSS::InvalidRSSError
      'RSS was Invalid'
    end

    private

    def count_processed_lines(path)
      lines_read = %x{wc -l "#{path}"}.split.first.to_i
      pp "Number of URLs processed: #{lines_read}"
      lines_read
    end

    def process_input
      pp '--------------------'
      console_message
      handle_input
    end

    def handle_input
      gets.chomp
    end

    def console_message
      pp 'Introduce a RSS URL (or empty to exit)'
    end

    def read_rss(url)
      URI.open(url) do |rss|
        parse_rss(rss)
      end
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