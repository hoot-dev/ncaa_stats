require 'rubygems'
require 'nokogiri'
require 'open-uri'

('A'..'Z').each do |letter|
  url = "http://statsheet.com/mcb/teams/browse/name?t=#{letter}"
  doc = Nokogiri::HTML(open(url, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'))

  urls = doc.css('section#content td a').each_with_index.map { |anchor, index|
    "#{anchor['href']}/team_stats?type=all" if index % 2 == 0 }.compact

  File.open("team_urls", "a") do |file|
    urls.each do |url|
      file.puts url
    end
  end

  puts "Finished: #{letter}"
end
