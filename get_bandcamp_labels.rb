class GetBandcampLabels

  def self.run(query:, page: 1, memo: [])
    results = get_labels(query, page)
    memo.concat(format_res results, query)
    results.empty? ? memo : run(query: query, page: page + 1, memo: memo)
  end

  class << self
    private
    def get_labels(query, page)
      puts "querying #{page}".green
      JSON.parse(`coffee get_bc_page.coffee #{query} #{page}`).select do |obj|
        obj["type"] == "label"
      end
    end
    def format_res(results, query)
      results.map do |res|
        OpenStruct.new.tap do |obj|
          obj[:name] = res["name"] rescue byebug
          puts "name: #{obj[:name]}".blue
          obj[:content] = <<-MD
            <a href='#{res["url"]}'>#{res["name"]}</a>
            <br>
            <img src='#{res["imageUrl"]}' />
          MD
          puts "keys: " + res.keys.join(",").blue
          obj[:tags] = res["tags"].concat [query]
          puts "tags: #{obj[:tags].join(",")}".blue
          puts ("-" * 10).yellow
        end
      end
    end
  end

end
