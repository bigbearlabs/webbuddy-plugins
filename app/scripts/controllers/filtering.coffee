# TODO move out integration with host env into a service or module.
# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular, webbuddy) ->

    ## statics

    $scope.view_model ||=
      limit: 50
      sort: '-last_accessed_timestamp'
      show_dev: ->
        webbuddy.env.name is 'stub'
      matcher: (e)->
        # this should be passed into #filter - treat it as a strategy.


      # show_dev: true

    $scope.collection_options =
      itemSelector: '.item'
      layoutMode: 'vertical'
      filter: '.hit'

    webbuddy.reg_on_data ->
      scope.refresh_data data
      scope.$apply()


    ## view-model observations.

    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      # filter data
      $scope.filter()


      # $scope.highlight()  # PERF

      # FIXME ensure we see logging.
      # throw "test exception from data.input watch"


    ## view-model ops.

    $scope.refresh_data = (data)->
      ## process the data a bit. REFACTOR

      # convert searches into hash for easy delta application.
      if data.searches instanceof Array
        data.searches = webbuddy.to_hash data.searches, 'name'

      $scope.data = data
      $scope.filter()


    # for serious development in coffeescript, we need a way to extract stuff like this into separate code modules really quickly. still looking for an agile enough solution.

    name_match = (e, input)->
      if input.length is 0
        return true

      # case-insensitive match of names.
      e.name?.toLowerCase().match input.toLowerCase()

    $scope.match_searches = (searches, input = '')->
      searches.filter (search)->
        matched = name_match search, input
        # or
        # # any page matches.
        # search.pages?.filter((e)-> name_match e).length > 0

        # update the view model item.
        search.matched = matched

        matched

      # # return all searches as rendering is determined by class.
      # searches


    ## ui ops.

    $scope.classes = (item) ->
      hit: item.matched
      selected: $scope.view_model.selected_item == item


    $scope.highlight = (input = $scope.data?.input) ->
      $timeout ->
        # apply highlights. BAD-DEP
        $('body').highlightRegex()
        $('body').highlightRegex new RegExp input, 'i'


    $scope.preview = (item) ->
      $scope.view_model.selected_item = item
      $scope.view_model.detail =
        if item
          name: item.name
          items: if item.pages then item.pages else [ item ]
        else
          null

    $scope.hide_preview = (item) ->
      $scope.view_model.detail = null


    update_search_hits = (sync_reference, sync_target)->
      ## complicated logic to sync arrays.

      unless sync_target
        $scope.view_model.hits = _.clone sync_reference
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

    # REFACTOR to a service
    update_smart_stacks = ->
      # update_stack 'Pages',
      #   (matcher)->
      #     $scope.data.stacks.map((e)-> e.pages).filter (page)->
      #       matcher.match page


    $scope.filter = (input = $scope.data?.input)->
      console.log("filtering for #{input}")

      ## filter the view model and update views.

      $scope.view_model.searches = $scope.match_searches _.values($scope.data?.searches), $scope.data?.input

      # disable pages for now.
      # $scope.view_model.pages = $scope.data?.pages?.filter (page)->
      #   page.name?.toLowerCase().match input.toLowerCase()

      update_smart_stacks()

      # # init view model.
      # if $scope.view_model?.hits != $scope.view_model.searches
      #   $scope.view_model.hits = $scope.view_model.searches

      $scope.view_model.hits = $scope.view_model.searches

      # invoke preview on the first hit.
      $scope.preview $scope.view_model.searches[0]

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
        $scope.refresh_data data

        # signal all data reloaded
        $scope.refresh_collection()


    ## doit.

    collection_containers.map (selector)->
      $scope.init_collection selector

    $scope.fetch_data()

    # sometimes the bridge can attach late. register an event listener to guard against such cases.
    post_bridge_attach = ->
      $scope.fetch_data()

    document.addEventListener "WebViewJavascriptBridgeReady", post_bridge_attach, false




