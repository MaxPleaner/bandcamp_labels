require 'nokogiri'
require 'open-uri'

module Seed
  def self.create(name:,content:,tags:)
    name.gsub!("/", "_")
    raise ArgumentError unless [name, content].all? { |x| x.is_a?(String) && x.length > 0 }
    raise ArgumentError unless tags.is_a?(Array) && tags.length > 0
    path = (ENV["STATIC_SEED_PATH"] || `pwd`.chomp) + "/source/markdown/#{name}.md.erb"
    metadata_string = "**METADATA**\nTAGS: #{tags.join(", ")}\n****\n"
    File.open(path, 'w') { |file| file.write("#{metadata_string}#{content.strip_heredoc}") }
  end
  
end

if __FILE__ == $0
  if (json_list=ARGV.shift) && (objects = JSON.parse(json_list))
    objects.each { |obj| Seed.create(obj) }  
  else
    Seed.create(
     name: "sample page click me)",
     content: "#### It's a markdown page",
     tags: ["sample tag"]
   )
    puts "Seeded a sample markdown page"
  end
end
