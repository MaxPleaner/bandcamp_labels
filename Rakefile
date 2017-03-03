require 'rake'
require './get_bandcamp_labels'
require './seed'
require 'byebug'
require 'json'
require 'colored'
require "awesome_print"
require "active_support/all"

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
  `ruby gen.rb`
end
