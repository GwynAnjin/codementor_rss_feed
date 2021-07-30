require 'rss'
require 'open-uri'
require_relative 'parser'

class Reader
  class << self
    def from_file(path)
      return 'File does not exist' unless File.exist?(path)
      File.open(path, 'r') do |f|
        f.each do |line|
          read_rss(line.chomp)
        end
      end
      lines_read = %x{wc -l "#{path}"}.split.first.to_i
      # pp "Number of URLs processed: #{lines_read}"
      lines_read
    end
  
    def from_console
      url = process_input
      until url.empty? do
        read_rss(url)
        url = process_input
      end
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
      pp 'Introduce another RSS URL (or empty to exit)'
    end

    def use_own_parser(url)
      URI.open(url) do |xml|
        Parser.process_xml(xml)
      end
    end

    def read_rss(url)
      URI.open(url) do |rss|
        parse_rss(rss)
      end
    rescue URI::InvalidURIError => ex
      pp 'There was a problem with the URL Provided'
      pp ex
    end
  
    def parse_rss(rss)
      feed = RSS::Parser.parse(rss)
      iterate_result(feed)
    rescue RSS::InvalidRSSError => ex
      pp 'RSS was Invalid'
      pp ex
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