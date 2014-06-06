# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

class RenderableList
  constructor: (@items = []) ->

  add: (item) ->
    @items.push item

  items: -> @items  # sadly we must expose this for ng-repeat.

  item_prototype:
    on_select: ->
      console.log this

  # TODO remove(item)
  # TODO order(order_spec)
  # TODO filter(filter_spec)
  # TODO move(item)


angular.module('app')
  .controller 'ListCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

    $scope.list = new RenderableList $scope.data

    # RELOCATE to a host_env service.
    $scope.dispatch_action = (action) ->
      console.log "TODO dispatch #{action}"

      if typeof(action) is 'string'
        data =
          name: 'action'
          value: action

        url = "perform?op=send_data&data=#{encodeURIComponent(JSON.stringify data)}"
        window.location = url
      else
        # assume proc.
        action()

    # actionUpdated = (defaultName, value) ->
    #   # send down to the hosting layer.
    #   data =
    #     name: defaultName
    #     value: value
    #   url = "perform?op=send_data&data=#{encodeURIComponent(JSON.stringify data)}"

    #   # $.get url
    #   # WORKAROUND doesn't hit the delegate method.
    #   window.location = url


