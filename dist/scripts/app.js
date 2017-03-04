(function() {
  var addButtonToShowAll, buildNavbarTagsMenu, filterGrid, gridItemOnClick, gridItemOnMouseenter, gridItemOnMouseleave, hideAllContent, indexTagForSearch, initLunrSearchIndexes, initTagSearch, isotopeFilterFn, loadInitialState, metadataOnClick, refreshGrid, setupGrid, setupImagesOnHover, setupMetadata, showAllButtonOnClick, togglingContentOnMouseenter, togglingContentOnMouseleave;

  gridItemOnClick = function($grid, e) {
    var $content, $el, contentAlreadyHidden;
    e.stopPropagation();
    $el = $(e.currentTarget);
    $content = $($el.find(".content")[0]);
    if ($grid.find(".content:not(.hidden)").length > 0) {
      contentAlreadyHidden = $content.hasClass("hidden");
      hideAllContent($grid);
      if (contentAlreadyHidden) {
        $content.removeClass("hidden");
      }
    } else {
      $content.removeClass("hidden");
    }
    return refreshGrid($grid);
  };

  hideAllContent = function($grid) {
    return $grid.find(".content").addClass("hidden");
  };

  isotopeFilterFn = function() {
    var currentTag, isVisible, tags;
    tags = $(this).data("tags");
    currentTag = window.currentTag;
    if (currentTag) {
      isVisible = (tags.length > 0) && tags.includes(currentTag);
    } else {
      isVisible = true;
    }
    return isVisible;
  };

  filterGrid = function($grid) {
    return $grid.isotope({
      filter: isotopeFilterFn
    });
  };

  gridItemOnMouseenter = function(e) {
    return $(e.currentTarget).addClass("selected-grid-item");
  };

  gridItemOnMouseleave = function(e) {
    return $(e.currentTarget).removeClass("selected-grid-item");
  };

  togglingContentOnMouseenter = function(e) {
    return $(e.currentTarget).parents(".grid-item").removeClass("selected-grid-item");
  };

  togglingContentOnMouseleave = function(e) {
    return $(e.currentTarget).parents(".grid-item").addClass("selected-grid-item");
  };

  setupGrid = function($grid, $gridItems, $togglingContent) {
    $gridItems.on("click", curry(gridItemOnClick)($grid));
    $togglingContent.on("click", function(e) {
      return e.stopPropagation();
    });
    $togglingContent.addClass("hidden");
    $gridItems.on("mouseenter", gridItemOnMouseenter);
    $gridItems.on("mouseleave", gridItemOnMouseleave);
    $togglingContent.on("mouseenter", togglingContentOnMouseenter);
    $togglingContent.on("mouseleave", togglingContentOnMouseleave);
    return $grid.isotope({
      itemSelector: '.grid-item',
      layoutMode: 'fitRows'
    });
  };

  refreshGrid = function($grid) {
    return $grid.isotope();
  };

  loadInitialState = function($grid) {
    var currentTag;
    currentTag = window.location.hash.replace("#", "");
    if (currentTag.length > 0) {
      window.currentTag = currentTag;
      return filterGrid($grid);
    }
  };

  metadataOnClick = function($grid, e) {
    var tag;
    tag = $(e.currentTarget).text();
    window.location.hash = tag;
    window.currentTag = tag;
    filterGrid($grid);
    return e.preventDefault();
  };

  setupMetadata = function($grid, $metadata) {
    var $navbarTagsMenu;
    $metadata.addClass("hidden");
    $navbarTagsMenu = buildNavbarTagsMenu($grid, $metadata);
    $nav.append($navbarTagsMenu);
    return $nav.on(".tagLink", "click", curry(metadataOnClick)($grid));
  };

  window.tagLinks = {};

  buildNavbarTagsMenu = function($grid, $metadata) {
    var $navbarTagsMenu, tags;
    $navbarTagsMenu = $("<div id='navbarTags'></div>");
    tags = $.map($metadata, function(node) {
      var $node, nodeJson;
      $node = $(node);
      nodeJson = $node.text();
      tags = JSON.parse(nodeJson)['tags'];
      $node.parents(".grid-item").data("tags", tags);
      return tags;
    });
    tags = Array.from(new Set(tags)).sort();
    tags.forEach(function(tag, tdx) {
      var $tagLink;
      indexTagForSearch(tag, idx);
      $tagLink = $("<a></a>").html(tag).addClass("tagLink").addClass("hidden").attr("href", "#");
      tagLinks[tag] = $tagLink;
      return $navbarTagsMenu.append($tagLink);
    });
    addButtonToShowAll($grid, $navbarTagsMenu);
    return $navbarTagsMenu;
  };

  indexTagForSearch = function(tag, idx) {
    return lunrTagsIndex.add({
      id: idx,
      name: tag
    });
  };

  addButtonToShowAll = function($grid, $navbarTagsMenu) {
    var $button;
    $button = $("<a></a>").html("all").addClass("showAllLink").attr("href", "#");
    $navbarTagsMenu.prepend($button);
    return $button.on("click", curry(showAllButtonOnClick)($grid));
  };

  showAllButtonOnClick = function($grid, e) {
    window.location.hash = "";
    window.currentTag = void 0;
    filterGrid($grid);
    return e.preventDefault();
  };

  setupImagesOnHover = function($gridItems) {
    return $gridItems.find("img").on("mouseenter", function(e) {
      var $img;
      $img = $(e.currentTarget);
      return $img.attr("src", $img.data('src'));
    });
  };

  initLunrSearchIndexes = function() {
    return window.lunrTagsIndex = lunr(function() {
      this.field('name');
      return this.ref('id');
    });
  };

  window.last_search_text_typed_at = void 0;

  window.showingTags = [];

  initTagSearch = function() {
    var $search_input;
    $search_input = $nav.find("#tag-search");
    return $search_input.on("keydown", function(e) {
      var last_search_text_typed_at;
      last_search_text_typed_at = (new Date()).getTime();
      return setTimeout(function() {
        var current_time, results, tag_to_show, tags_to_hide, text;
        current_time = (new Date()).getTime();
        if (current_time - last_search_text_typed_at > 250) {
          text = $search_input.val();
          results = lunrTagsIndex.search(text);
          tags_to_hide = showingTags.forEach(function($tag) {
            return $tag.hide();
          });
          window.showingTags = [];
          tag_to_show = results.map(function(result_tag) {
            return tagLinks[result_tag];
          });
          debugger;
        }
      }, 250);
    });
  };

  $(function() {
    var $grid, $gridItems, $metadata, $nav, $togglingContent;
    $grid = $(".grid");
    $gridItems = $grid.find(".grid-item");
    $togglingContent = $gridItems.find(".content");
    $metadata = $grid.find(".metadata");
    $nav = $("#nav");
    setupMetadata($grid, $metadata);
    loadInitialState($grid);
    setupGrid($grid, $gridItems, $togglingContent);
    setupImagesOnHover($gridItems);
    initLunrSearchIndexes();
    return initTagSearch();
  });

}).call(this);
