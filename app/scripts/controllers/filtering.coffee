# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('app')
  .controller 'FilteringCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

    ## statics

    $scope.$root.pageTitle = 'WebBuddy Filtering'

    $scope.view_model ||=
      show_dev: true

      classes:
        stack_content_item_label:
          hidden: false
        command_bar:
          hidden: true
        stack: {}

      # master
      subsection_order: [
        'favorites', 'highlights', 'searches', 'pages', 'suggestions',
      ]
      limit: 20

      sort: [ 'subsection_order', '-last_accessed' ]

      limit_detail: 20
      detail:
        sort: '-last_accessed'
        template: 'thumbnail-grid.html'

      ## data

      subsections:
        favorites:
          name: 'favorites'
          items: []
        searches:
          name: 'searches'
          items: []

      singular_subsection:
        name: 'singular subsection'
        items: []


      match_strategies: webbuddy.match_strategies

      match_strategy: ->
        webbuddy.match_strategies['name_match']

    $scope.view_model.match_strategy_text = $scope.view_model.match_strategy().toString()

    $scope.collection_options =
      itemSelector: '.item'
      layoutMode: 'vertical'
      filter: '.hit'


    ## data ops

    $scope.update_data = (data)->
      webbuddy.transform_data data

      $scope.data = data

    $scope.update_match_strategy = (data) ->
      result = eval "(#{$scope.view_model.match_strategy_text})"
      $scope.view_model.match_strategy = result
      true


    ## ui accessors

    $scope.classes = (item) ->
      classes =
        hit: item.matched
        selected: $scope.view_model.selected_item == item
      classes[item.name] = true
      classes

    $scope.href = (item) ->
      # return an href only if item is ready for navigation.
      $timeout ->   # work around the click registering to the a href when selecting.
        if item is $scope.view_model.selected_item
          item.url
        else
          ''

    $scope.first_visible_item = ->
      _($scope.view_model.subsections)
        .values()
        .select( (e)-> e.items.length > 0 )
        .sortBy( (e)-> $scope.view_model.subsection_order.indexOf e.name )
        .compact()
        .value()[0]
        ?.items[0]

    ## ui ops

    $scope.tooltip = (item) ->
      item.name +
        "\n" + item.url +
        "\n" + 'Last accessed: ' + item.last_accessed

    $scope.template = (subsection) ->
      if subsection.name == 'suggestions'
        'item-text.html'
      else
        'item-thumbnail-grid.html'


    # PERF
    $scope.highlight = (input = $scope.data?.input) ->
      $timeout ->
        $('.stack, .detail').highlightRegex()

        # apply highlights. BAD-DEP
        $('.stack, .detail').highlightRegex new RegExp input, 'i'

        # hackily unhighlight titles.
        $('.detail h2').highlightRegex()


    $scope.preview = (item) ->
      console.log "previewing item #{item}"
      $scope.view_model.selected_item = item
      $scope.highlight()

    $scope.hide_preview = (item) ->
      $scope.view_model.selected_item = null

    $scope.reset_preview = ->
      $scope.preview $scope.first_visible_item()

    mirror_array = (sync_target, sync_reference)->

      unless sync_target
        $scope.view_model.subsections[0].items = _.clone sync_reference
        return

      intersection = _.intersection sync_reference, sync_target
      to_add = _.difference sync_reference, intersection
      to_remove = _.difference sync_target, intersection

      # remove all in to_remove.
      for i in [(sync_target.length - 1)...-1]
        e = sync_target[i]
        if _.include to_remove, e
          sync_target.splice i, 1

      # add all i to_add.
      to_add.map (e)-> sync_target.push e


    $scope.filter = debounce 200, (input = $scope.data?.input)->

      console.log("filtering for #{input}")

      ## filter the view model and update views.

      all_searches = _.values($scope.data?.searches)

      # $scope.add_notables input

      # 0.1-UNSTABLE
      matching_searches = webbuddy.match $scope.view_model.match_strategy(), all_searches, $scope.data?.input
      matching_searches.map (e) ->
        e.thumbnail_url = 'img/stack.png'

      $scope.view_model.subsections['searches'].items = _.sortBy( matching_searches, (e) -> e.last_accessed ).reverse()

      # pages, suggestions, highlights. PERF
      webbuddy.smart_stacks all_searches, input, (each_stack)->
        stack_view_model =
          name: each_stack.name,
          items:
            # cases
            if each_stack.name == 'pages'
              # all pages should create 1 stack.
              if each_stack.items.length > 0
                [ each_stack ]
              else
                []
            else
              each_stack.items

        # set smart stacks as subsections
        $scope.view_model.subsections[each_stack.name] = stack_view_model

        $scope.reset_preview()


      $scope.refresh_collection_filter()


    ## collection bits.

    # collection_containers = [ '.search-list', '.page-list', '.suggestion-list' ]
    collection_containers = [ '.hit-list' ]

      # sortBy: 'name'  # TEMP
      # getSortData:
      #   name: ($elem)-> $elem.find('a').attr('title')

    # initialise isotope.
    $scope.init_collection = (selector_for_container)->
      # $timeout ->
        # remove all comments in ng-repeat sections for better isotope behaviour.
        # comments = $('.hit-list').contents().filter ->
        #   this.nodeType == 8
        # comments.remove()

        # # add the isotope-container attr to the containers to avoid clash with ng-repeat.
        # $('.hit-list').attr 'isotope-container', ''
        # $('.hit-list > .item').attr 'isotope-item', ''

      # $(selector_for_container).isotope $scope.collection_options

      # temp init (we think.)
      # $(selector_for_container).isotope $scope.collection_options

    $scope.refresh_collection = (selector_for_container = collection_containers)->

      # $timeout ->
      #   collection_containers.map (selector_for_container) ->
      #     $(selector_for_container).isotope('reloadItems').isotope()

    $scope.refresh_collection_filter = (selector_for_container = collection_containers)->
      # $timeout ->
      #   collection_containers.map (selector_for_container) ->
      #     $(selector_for_container).isotope()


    $scope.fetch_data = (data_url)->
      data_url ||= webbuddy.env.data_pattern.replace '#{name}', 'filtering'
      console.log "fetch data from #{data_url} (env #{webbuddy.env.name})"
      data_url = data_url.replace '://', '@scheme_token@'  # escape scheme.
      [ base_segs..., last_seg ] = data_url.split '/'
      base_url = base_segs.join('/').replace('@scheme_token@', '://')
      Restangular.setBaseUrl base_url
      Restangular.one(last_seg).get()
      .then (data)->
        $scope.update_data data

        $scope.filter()

        # signal all data reloaded
        $scope.refresh_collection()


    ## doit.

    # TODO broken after refactoring affecting singular_subsection.
    item_at_delta = (delta) ->
      items = $scope.view_model.singular_subsection.items
      selected_item = $scope.view_model.selected_item
      current_index = items.indexOf selected_item
      new_index = current_index + delta
      new_index = Math.min(Math.max(new_index, 0), items.length - 1)
      return items[new_index]

    # register event handlers.
    $('body').on 'keydown', (event)->
      console.log event.keyCode

      switch event.keyCode
        # when 13  # enter
        #   webbuddy.on_input_field_submit $scope.data.input
        #   return
        when 38  # up
          delta = -1
        when 40  # down
          delta = 1
        else
          return

      # we have a delta.
      event.preventDefault()
      $scope.preview item_at_delta delta

      # TODO scroll into view.


    # # register callback with service.
    # webbuddy.reg_on_data
    #   -> $scope.data
    #   , (data)->
    #     $scope.update_data data
    #     $scope.filter()
    #     $scope.$apply()

    # workaround.
    $window.webbuddy.on_data = (new_data)->
      data = _.clone $scope.data or {}

      webbuddy.fold_data new_data, data
      webbuddy.update_items data

      $scope.update_data data
      $scope.filter()
      $scope.$apply()

    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      # filter data
      $scope.filter()

      $scope.highlight()

      # FIXME ensure we see logging.
      # throw "test exception from data.input watch"

    # init collection.
    collection_containers.map (selector)->
      $scope.init_collection selector

    # get some data.
    $scope.fetch_data()

    # sometimes the bridge can attach late. register an event listener to guard against such cases.
    post_bridge_attach = ->
      $scope.fetch_data()
    document.addEventListener "WebViewJavascriptBridgeReady", post_bridge_attach, false


    # MOVE input field ops.
    $scope.focus_input_field = () ->
      $('#input-field')[0].select();

    $('#input-field').focusin ->
      webbuddy.on_input_field_focus()
    $('#input-field').focusout ->
      webbuddy.on_input_field_unfocus()

angular.module('app')
  # an enableWhen has click enabled only when it's selected.
  .directive 'enableWhen', (webbuddy)->
    restrict: 'A'
    link: (scope, elem, attrs)->
      elem.on 'click', (event) ->

        # event.preventDefault() unless elem.parents('.stack').hasClass('selected')

        event.preventDefault()

        item = angular.element(elem).scope().detail_item
        console.log
          item: item
          elem: elem
        if elem.parents('.stack').hasClass('selected')
          webbuddy.on_item_click item

        event

  # a focusable comes into focus when clicked.
  .directive 'focusable', ($timeout)->
    restrict: 'A'
    link: (scope, elem, attrs)->
      elem.on 'click', (event)->
        $timeout ->  # work around selected class application not being quick enough.
          elem[0].scrollIntoView()

  .directive 'focusOnSelected', ->
    restrice: 'A'
    link: (scope, elem, attrs)->
      scope.$watch 'view_model.selected_item', ->
        if scope.item == scope.view_model.selected_item
          console.log {
            scope,
            elem,
            attrs,
            item: scope.item
            view_model: scope.view_model
          }
          elem[0].scrollIntoView()



