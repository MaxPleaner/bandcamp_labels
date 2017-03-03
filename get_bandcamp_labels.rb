class GetBandcampLabels

  def self.run(query:, page: 1, memo: [])
    results, done = get_labels(query, page)
    memo.concat(format_res results, query)
    (done || page > 6) ? memo : run(query: query, page: page + 1, memo: memo)
  end

  class << self
    private
    def get_labels(query, page)
      sleep 0.5
      puts "querying #{page}".green
      objects = JSON.parse(`coffee get_bc_page.coffee #{query} #{page}`)
      labels = objects.select do |obj|
        obj["type"] == "label"
      end
      [labels, objects.empty?]
    end
    def format_res(results, query)
      results.map.with_index do |res|
        OpenStruct.new.tap do |obj|
          obj[:name] = res["name"]
          puts "name: #{obj[:name]}".blue
          obj[:tags] = res["tags"]
          obj[:tags].concat(["unknown"]) if obj[:tags].empty?
          obj[:content] = <<-MD
            <a href='#{res["url"]}'>#{res["name"]}</a>
            <br>
            <img src='#{res["imageUrl"]}' />
            <br>
            tags: #{obj[:tags].join(",")}
          MD
          puts "tags: #{obj[:tags].join(",")}".blue
          puts ("-" * 10).yellow
        end
      end
    end
  end

end
