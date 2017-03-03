query = process.argv[2]
page = process.argv[3]
throw("missing command line arg (query)") unless (query && page)

bc = require 'bandcamp-scraper'
bc.search query: query, page: parseInt(page), (err, res) ->
  console.log(JSON.stringify res)
