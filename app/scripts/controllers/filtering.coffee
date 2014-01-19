# TODO move out integration with host env into a service or module.
# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular, webbuddy) ->

    ## statics

    $scope.view_model ||=
      limit: 5
      limit_detail: 20
      sort: '-last_accessed_timestamp'
      show_dev: ->
        webbuddy.env.name is 'stub'
      matcher: (e)->
        # this should be passed into #filter - treat it as a strategy.


    $scope.collection_options =
      itemSelector: '.item'
      layoutMode: 'vertical'
      filter: '.hit'


    ## data ops.

    $scope.update_data = (data)->
      webbuddy.transform_data data

      $scope.data = data


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

    $scope.hide_preview = (item) ->
      $scope.view_model.selected_item = null


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


    $scope.filter = (input = $scope.data?.input)->
      console.log("filtering for #{input}")

      ## filter the view model and update views.

      all_searches = _.values($scope.data?.searches)

      matching_searches = webbuddy.match 'name_match', all_searches, $scope.data?.input

      # build the final view model.
      $scope.view_model.hits = _.sortBy( matching_searches, (e) -> e.last_accessed_timestamp ).reverse()

      $scope.view_model.smart_stacks = webbuddy.smart_stacks all_searches, input  # pages, suggestions, highlights PERF

      # reset selected item.
      item_to_preview = $scope.view_model.hits[0]
      item_to_preview ||= $scope.view_model.smart_stacks[0]
      $scope.preview item_to_preview

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

    # # register callback with service.
    # webbuddy.reg_on_data
    #   -> $scope.data
    #   , (data)->
    #     $scope.update_data data
    #     $scope.filter()
    #     $scope.$apply()

    # workaround.
    window.webbuddy.on_data = (new_data)->
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

      $scope.highlight()  # PERF

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




