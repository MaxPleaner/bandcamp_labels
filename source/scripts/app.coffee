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
  $nav.on ".tagLink", "click", curry(metadataOnClick)($grid)

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
  tags.forEach (tag, tdx) ->
      indexTagForSearch(tag, idx)
      $tagLink = $("<a></a>").html(tag)
                            .addClass("tagLink")
                            .addClass("hidden")
                            .attr("href", "#")
      tagLinks[tag] = $tagLink
      $navbarTagsMenu.append($tagLink)
  addButtonToShowAll($grid, $navbarTagsMenu)
  return $navbarTagsMenu

indexTagForSearch = (tag, idx) ->
  lunrTagsIndex.add
    id: idx
    name: tag


addButtonToShowAll = ($grid, $navbarTagsMenu) ->
  $button = $("<a></a>").html("all")
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
      if current_time - last_search_text_typed_at > 250
        text = $search_input.val()
        results = lunrTagsIndex.search text
        tags_to_hide = showingTags.forEach ($tag) -> $tag.hide()
        window.showingTags = []
        tag_to_show = results.map (result_tag) ->
          tagLinks[result_tag]
        debugger
    , 250
  
$ () ->

  $grid            = $ ".grid"
  $gridItems       = $grid.find ".grid-item"
  $togglingContent = $gridItems.find ".content"
  $metadata        = $grid.find ".metadata"
  $nav             = $("#nav")
  
  setupMetadata($grid, $metadata)
  loadInitialState($grid)
  setupGrid($grid, $gridItems, $togglingContent)
  setupImagesOnHover($gridItems)
  initLunrSearchIndexes()
  initTagSearch()
    
