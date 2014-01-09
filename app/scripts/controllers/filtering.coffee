# TODO move out integration with host env into a service or module.
# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('modulesApp')
  .controller 'FilteringCtrl', ($scope, $window, $timeout, $q,
    Restangular) ->

    ## interfacing with hosting env.

    to_hash = (array, key_property)->
      # do nothing if already a hash.
      return array unless (array instanceof Array)

      array.reduce (acc, e)->
        key = encodeURIComponent e[key_property]
        acc[key] = e
        acc
      , {}

    # attach data handler to the bridge
    webbuddy.on_data = (new_data)->
      data = _.clone $scope.data
      data ||= {}

      for k, v of new_data

        if k.indexOf('_delta') >= 0
          # for keys /.*_delta/, merge values with existing key.

          k = k.replace '_delta', ''
          v_hash = to_hash v, 'name'

          delta_applied = _.clone data[k]
          for delta_k, delta_v of v_hash
            console.log "setting #{k}.#{delta_k} to #{delta_v}"
            delta_applied[delta_k] = delta_v

          data[k] = delta_applied
        else
          # just add to the data.

          console.log "setting #{k}"
          data[k] = v

      $scope.refresh_data data
      $scope.$apply()

    # also expose the scope for data retrieval. WIP
    webbuddy.scope = $scope

    # FIXME refactor the above into a service that represents the host env.


    ## view-model observations.

    # watch model to trigger view behaviour.
    $scope.$watch 'data.input', ->
      $scope.filter()

    # FIXME when this code path throws, it will be silent from webbuddy. not good


    ## view-model ops.

    $scope.refresh_data = (data)->
      $timeout ->
        # console.log "refreshing data: #{JSON.stringify data}"

        # convert searches into hash.
        if data.searches
          data.searches = to_hash data.searches, 'name'

        $scope.data = data
        $scope.filter()
        $scope.$apply()
        # FIXME this will potentially trigger filtering twice after the watch on data.input

    # for serious development in coffeescript, we need a way to extract stuff like this into separate code modules really quickly. still looking for an agile enough solution.
    $scope.matching_searches = (searches, input = '')->
      if input.length is 0
        return searches

      name_match = (e)->
        e.name?.toLowerCase().match input.toLowerCase()

      searches
        .filter (search)->
          # case-insensitive match of names.
          name_match(search) or
            # or
            # regular expression match of names. TODO
            # any page matches.
            search.pages?.filter((e)-> name_match e).length > 0



    ## ui ops.

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

    $scope.$root.filter = (input = $scope.data?.input)->
      console.log("filtering for #{input}")

      ## filter the view model and update views.

      update_search_hits = ->
        sync_reference = $scope.view_model.searches
        sync_target = $scope.view_model.hits

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


      update_smart_stacks = ->
        console.log 'todo'


      $scope.view_model.searches = $scope.matching_searches _.values($scope.data?.searches), $scope.data?.input

      $scope.view_model.pages = $scope.data?.pages?.filter (page)->
        page.name?.toLowerCase().match input.toLowerCase()

      update_search_hits()
      update_smart_stacks()

      # invoke preview on the first hit.
      $scope.preview $scope.view_model.hits[0]

      # we must re-isotope to avoid errors from isotope due to deviation between model and jquery objs.
      $scope.reisotope '.hit-list'


    $scope.classname = (item) ->
      classname =
        if $scope.view_model.selected_item is item
          'selected'
        else
          ''


    # dev-only
    $scope.fetch_stub_data = ->
      stub_data_rsc = 'filtering.json'
      console.log "fetch stub data from #{stub_data_rsc}"
      Restangular.setBaseUrl "data"
      Restangular.one(stub_data_rsc).get()
      .then (data)->
        $scope.refresh_data data


    ## statics
    $scope.view_model ||=
      limit: 5
      show_dev: webbuddy.env.name is 'stub'
      # show_dev: true


    ## isotope bits.

    # isotope_containers = [ '.search-list', '.page-list', '.suggestion-list' ]
    isotope_containers = [ '.hit-list' ]

    $scope.isotope_options =
      itemSelector: '.item'
      layoutMode: 'straightDown'
      # layoutMode: 'straightAcross'
      # sortBy: 'name'  # TEMP
      # getSortData:
      #   name: ($elem)-> $elem.find('a').attr('title')

    # initialise isotope.
    $scope.isotope = (selector_for_container)->
      # $timeout ->
      #   $(selector_for_container).isotope $scope.isotope_options

    $scope.reisotope = (selector_for_container)->
      # $timeout ->
      #   $(selector_for_container).isotope('reloadItems').isotope()


    ## doit.
    # FIXME make polymorphic.
    switch webbuddy.env.name
      when 'stub'
        $scope.fetch_stub_data()


    # isotope doit.
    isotope_containers.map (selector)->
      $timeout ->
        $scope.isotope selector


