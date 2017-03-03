### What it is

A website indexing the labels on bandcamp.

### How it's built

To get the search results from bandcamp, I'm using the `bandcamp-scraper` npm tool
with coffeescript.

This coffeescript is called by ruby in order to get a listing of labels.
Markdown pages are then build for each label, which plug into my
[static](http://github.com/maxpleaner/static) website generator.
The result of this is a static website that can be deployed to github pages or
wherever. 

### How to use

1. The first step is to clone the repo. However this will not give you a app in
full working order. Certain folders (dist/, source/markdown, node_modules) are
present in gitignore. But no worry - these can all be populated automatically.
2. Run `npm install` and `bundle` to get the dependencies
3. Run `bundle exec rake get_labels[metal]` to create markdown pages for the metal
labels. You can substitute `metal` for your own query, like `electroacoustic` or
`plunderphonics` (I don't know if there are actually any results for these). 
4. Run `ruby gen.rb` to compile the markdown pages into a static website.
5. Either open `dist/index.html` from your browser, or run `ruby webrick.rb` then
visit `http://localhost:8000` in your browser.
6. Create a new github repo and point your origin to it. Then run the `push_dist_to_gh_pages`
script and voila, you have a public website. 

### Development / Goals

The bandcamp-scraper tool is not returning all the results. For example, a "metal"
query only returns 8 labels. This is obviously not all the ones that exist. So I need
to figure out how to get a larger number for this website to actually be useful. 
