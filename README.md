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

1. The first step is to clone the repo.
2. Run `npm install` and `bundle` to get the dependencies
3. Run `bundle exec rake get_labels[metal]` to create markdown pages for the metal
labels. You can substitute `metal` for your own query, like `electroacoustic` or
`plunderphonics` (I don't know if there are actually any results for these). 
4. Run `ruby gen.rb` to compile the markdown pages into a static website.
5. Either open `dist/index.html` from your browser, or run `ruby webrick.rb` then
visit `http://localhost:8000` in your browser.
6. Create a new github repo and point your origin to it. Then run the `push_dist_to_gh_pages`
script and voila, you have a public website. 

### Other notes

This repo is already seeded with the contents of the site as visible
[here](http://maxpleaner.github.io/bandcamp_labels). So there are 1k+ markdown
files in `source/markdown`, each representing a single level. `dist/index.html`
contains a contatenated index of all these. 

To seed this many listings, I started with my favorite genres then went through
the 1000 most popular words in the english language.
`rake seed_most_common_words` does this.

To seed even more listings, it's possible to run `rake seed_random` which queries
random words from the dictionary on a loop. 

### Development / Goals

The bandcamp-scraper tool is not returning all the results. For example, a "metal"
query only returns 8 labels. This is obviously not all the ones that exist. So I need
to figure out how to get a larger number for this website to actually be useful. 
