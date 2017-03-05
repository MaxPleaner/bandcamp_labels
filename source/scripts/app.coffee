
# gridItemOnClick = ($grid, e) ->
#   e.stopPropagation()
#   $el = $ e.currentTarget
#   $content = $ $el.find(".content")[0]
#   if $grid.find(".content:not(.hidden)").length > 0
#     contentAlreadyHidden = $content.hasClass "hidden"
#     hideAllContent($grid)
#     if contentAlreadyHidden
#       $content.removeClass("hidden")
#   else
#     $content.removeClass("hidden")
#   refreshGrid($grid)
  
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

initFilterLoading = ->
  window.$filterLoadingNote = $ """
    <b> loading </b>
  """
  $nav.append $filterLoadingNote

finishFilterLoading = ->
  $filterLoadingNote.remove()

setupGrid = ($grid) ->
  $grid.isotope("destroy") if window.has_isotope
  initFilterLoading()
  $grid.on "arrangeComplete", finishFilterLoading
  $grid.isotope
    itemSelector: '.grid-item'
    layoutMode: 'fitRows'
    filter: isotopeFilterFn
  window.has_isotope = true

metadataOnClick = ($grid, e) ->
  tag = $(e.currentTarget).text()
  window.currentTag = tag
  setupGrid($grid)
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
  $button = $("<a></a>").html("show all labels")
                        .addClass("showAllLink")
                        .attr("href", "#")
  $navbarTagsMenu.prepend($button)
  $button.on "click", curry(showAllButtonOnClick)($grid)
  
showAllButtonOnClick = ($grid, e) ->
  window.currentTag = undefined
  setupGrid($grid)
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

window.initApp = ->    
  window.$grid            = $ ".grid"
  window.$gridItems       = $grid.find ".grid-item"
  window.$togglingContent = $gridItems.find ".content"
  window.$metadata        = $grid.find ".metadata"
  window.$nav             = $("#nav")

  initLunrSearchIndexes()
  setupMetadata($grid, $metadata)
  setupGrid($grid)
  setupImagesOnHover($gridItems)
  initTagSearch()      
