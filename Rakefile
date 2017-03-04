require 'rake'
require './get_bandcamp_labels'
require './seed'
require 'byebug'
require 'json'
require 'colored'
require "awesome_print"
require "active_support/all"
require 'random-word'
require 'open-uri'
require 'nokogiri'

task :get_labels, [:query] do |t, args|
  query = args[:query]
  labels = GetBandcampLabels.run query: query
  labels.each do |label|
    Seed.create(
      name: label.name.gsub(" ", "_"), 
      content: label.content,
      tags: label.tags
    )
  end
end

task :seed_random do
  sources = [
    RandomWord.adjs,
    RandomWord.nouns
  ]
  loop do
    puts query
    Rake::Task[:get_labels].invoke(query)
    Rake::Task[:get_labels].reenable
  end
end

task :seed_most_common_words do
  File.readlines("most_common_words.txt").each do |query|
    query.gsub!(/[\'\"]/, '')
    puts query.chomp!
    Rake::Task[:get_labels].invoke(query)
    Rake::Task[:get_labels].reenable
  end
end

task :get_missing_tags do
  Dir.glob("./source/markdown/*").each do |path|
    text = File.read(path).chomp
    if text.ends_with?("unknown")
      url = text.scan(/href='(.+)'/).flatten.pop
      label_page = Nokogiri.parse open url
      # Label pages have a list of artists.
      # Click on the first one.
      artist_box = label_page.css(".artists-grid-item > a").shift
      if artist_box
        artist_url = artist_box.attributes["href"].value
        artist_page = Nokogiri.parse open artist_url
        # Sometimes artists have their homepage list albums
        # instead of showing the most recent album.
        # In this case, select the first album.
        extra_artist_box = artist_page.css(".music-grid_item > a").shift
        if extra_artist_box
          extra_artist_path = extra_artist_box.attributes["href"].value
          extra_artist_url = artist_url + extra_artist_path
          artist_page = Nokogiri.get open extra_artist_url
        end
        # Now it's surely on an album page, so fetch tags
        tag_box = artist_page.css(".tralbum-tags")
        tags = tag_box.text
                      .strip_heredoc
                      .split("\n")
                      .map(&:strip)
                      .reject(&:blank?)
                      .tap(&:shift)
        final_text = text.gsub("unknown", tags.join(", "))
        File.open(path, 'w') { |f| f.write final_text }
      end
    end
  end
end
