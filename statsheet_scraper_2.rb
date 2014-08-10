require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'


$team_hash = {}
user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'

# Team Name, Stats, & Slug
def get_team_stats(user_agent)
  File.readlines('team_urls').each do |url|
    doc = Nokogiri::HTML(open(url,
      'User-Agent' => user_agent))

    data = doc.css('table#tab1 td').each_with_index.map { |stat, index|
      if [0,1,4].include?(index % 9)
        stat.text
      end
    }.compact

    split_data = create_data_hash(data)

    name = get_team_name(doc)[0]

    team_slug = url.split('/')[5]
    $team_hash[team_slug] = {name: name, stats: split_data}

    puts "Finished: #{url}"
  end
end

def get_team_name(doc)
  doc.css('div.breadcrumbs a').each_with_index.map { |anchor, index|
    if index == 2
      anchor.text
    end
  }.compact
end

def create_data_hash(data)
  data.each_slice(3).map { |a,b,c|
    {a.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '') => [b, c]}
  }
end

# Team RPI & SOS
def get_team_rpi(user_agent)
  doc = Nokogiri::HTML(open('http://statsheet.com/mcb/rankings/RPI',
    'User-Agent' => user_agent))

  data = doc.css('table.stats td').each_with_index.map { |stat, index|
    if [1,4,5].include?(index % 11)
      if index % 11 == 1
        stat.css('a')[0]['href'].split('/')[3]
      else
        stat.text
      end
    end
  }.compact

  data.each_slice(3).each { |a,b,c|
    $team_hash[a][:stats] << {'rpi' => b}
    $team_hash[a][:stats] << {'sos' => c}
  }
end

get_team_stats(user_agent)
get_team_rpi(user_agent)

File.open("team_data.json", "a") do |file|
  file.puts $team_hash.to_json
end
