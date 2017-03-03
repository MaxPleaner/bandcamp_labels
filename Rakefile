require 'rake'
require './get_bandcamp_labels'
require './seed'
require 'byebug'
require 'json'
require 'colored'
require "awesome_print"
require "active_support/all"
require 'random-word'

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
    puts query.chomp!
    Rake::Task[:get_labels].invoke(query)
    Rake::Task[:get_labels].reenable
  end
end
