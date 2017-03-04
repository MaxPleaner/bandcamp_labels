gridItemOnClick = ($grid, e) ->
  e.stopPropagation()
  $el = $ e.currentTarget
  $content = $ $el.find(".content")[0]
  if $grid.find(".content:not(.hidden)").length > 0
    contentAlreadyHidden = $content.hasClass "hidden"
    hideAllContent($grid)
    if contentAlreadyHidden
      $content.removeClass("hidden")
  else
    $content.removeClass("hidden")
  refreshGrid($grid)
  
hideAllContent = ($grid) ->
  $grid.find(".content").addClass("hidden")

isotopeFilterFn = () ->
  tags = $(this).data("tags")
  currentTag = window.currentTag
  if currentTag
    isVisible = (tags.length > 0) && tags.includes(currentTag)
  else
    isVisible = true
  return isVisible

filterGrid = ($grid) ->
  $grid.isotope filter: isotopeFilterFn
  
gridItemOnMouseenter = (e) ->
  $(e.currentTarget).addClass("selected-grid-item")
  
gridItemOnMouseleave = (e) ->
  $(e.currentTarget).removeClass("selected-grid-item")

togglingContentOnMouseenter = (e) ->
  $(e.currentTarget).parents(".grid-item")
                    .removeClass("selected-grid-item")

togglingContentOnMouseleave = (e) ->
  $(e.currentTarget).parents(".grid-item")
                    .addClass("selected-grid-item")

setupGrid = ($grid, $gridItems, $togglingContent) ->
  $gridItems.on "click", curry(gridItemOnClick)($grid)
  $togglingContent.on "click", (e) -> e.stopPropagation()
  $togglingContent.addClass "hidden"
  $gridItems.on "mouseenter", gridItemOnMouseenter
  $gridItems.on "mouseleave", gridItemOnMouseleave
  $togglingContent.on "mouseenter", togglingContentOnMouseenter
  $togglingContent.on "mouseleave", togglingContentOnMouseleave
  $grid.isotope
    itemSelector: '.grid-item'
    layoutMode: 'fitRows'
  
refreshGrid = ($grid) ->
  $grid.isotope() # no need to re-supply initialization options

loadInitialState = ($grid) ->
  currentTag = window.location.hash.replace("#", "")
  if currentTag.length > 0
    window.currentTag = currentTag
    filterGrid($grid)

metadataOnClick = ($grid, e) ->
  tag = $(e.currentTarget).text()
  window.location.hash = tag
  window.currentTag = tag
  filterGrid($grid)
  e.preventDefault()

setupMetadata = ($grid, $metadata) ->
  $metadata.addClass "hidden"
  $navbarTagsMenu = buildNavbarTagsMenu($grid, $metadata)
  $nav.append($navbarTagsMenu)
  $(".tagLink").on "click", curry(metadataOnClick)($grid)

window.tagLinks = {}
buildNavbarTagsMenu = ($grid, $metadata) ->
  $navbarTagsMenu = $("<div id='navbarTags'></div>")
  tags = $.map $metadata, (node) ->
    $node = $ node
    nodeJson = $node.text()
    tags = JSON.parse(nodeJson)['tags']
    $node.parents(".grid-item").data("tags", tags)
    tags
  tags = Array.from(new Set(tags)).sort()
  tags.forEach (tag, idx) ->
      indexTagForSearch(tag, idx)
      $tagLink = $("<a></a>").html(tag)
                            .addClass("tagLink")
                            .addClass("hidden")
                            .attr("href", "#")
      tagLinks[idx] = $tagLink # The reference to look it up after searching
      $navbarTagsMenu.append($tagLink)
  addButtonToShowAll($grid, $navbarTagsMenu)
  return $navbarTagsMenu

indexTagForSearch = (tag, idx) ->
  lunrTagsIndex.add
    id: idx
    name: tag


addButtonToShowAll = ($grid, $navbarTagsMenu) ->
  $button = $("<a></a>").html("show all labels (allow 10-15 seconds to load)")
                        .addClass("showAllLink")
                        .attr("href", "#")
  $navbarTagsMenu.prepend($button)
  $button.on "click", curry(showAllButtonOnClick)($grid)
  
showAllButtonOnClick = ($grid, e) ->
  window.location.hash = ""
  window.currentTag = undefined
  filterGrid($grid)
  e.preventDefault()

setupImagesOnHover = ($gridItems) ->
  $gridItems.find("img").on "mouseenter", (e) ->
    $img = $ e.currentTarget
    $img.attr("src", $img.data('src'))

initLunrSearchIndexes = ->
  window.lunrTagsIndex = lunr ->
    this.field 'name'
    this.ref 'id'

window.last_search_text_typed_at = undefined
window.showingTags = []
initTagSearch = ->
  $search_input = $nav.find("#tag-search")
  $search_input.on "keydown", (e) ->
    last_search_text_typed_at = (new Date()).getTime()
    setTimeout ->
      current_time = (new Date()).getTime()
      if current_time - last_search_text_typed_at > 500
        text = $search_input.val()
        results = lunrTagsIndex.search text
        tags_to_hide = showingTags.forEach ($tag) -> $tag.hide()
        tags_to_show = results.map (result) ->
          tagLinks[result.ref]
        tags_to_show.forEach ($tag) -> $tag.show()
        window.showingTags = tags_to_show
    , 500
  
$ () ->

  window.$grid            = $ ".grid"
  window.$gridItems       = $grid.find ".grid-item"
  window.$togglingContent = $gridItems.find ".content"
  window.$metadata        = $grid.find ".metadata"
  window.$nav             = $("#nav")
  
  initLunrSearchIndexes()
  setupMetadata($grid, $metadata)
  loadInitialState($grid)
  setupGrid($grid, $gridItems, $togglingContent)
  setupImagesOnHover($gridItems)
  initTagSearch()

  # Doing this at the get go makes subsequent searches faster
  # Something about how masonry works?
  $(".showAllLink").trigger "click"
    
