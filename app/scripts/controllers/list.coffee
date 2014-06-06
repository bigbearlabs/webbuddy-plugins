# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

class RenderableList
  constructor: (@items = []) ->

  add: (item) ->
    @items.push item

  items: -> @items  # sadly we must expose this for ng-repeat.

  item_prototype:
    on_select: (item)->
      console.log item.action

  # TODO remove(item)
  # TODO order(order_spec)
  # TODO filter(filter_spec)
  # TODO move(item)


angular.module('app')
  .controller 'ListCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->

    # stub data.
    data = [
      description: 'Label...'
      on_select: 'set_name'
    ,
      description: 'Reset'
      on_select: 'reset'
    ,
      description: 'about'
      on_select: 'about'
    ,
    ]
    # what should the target be?


    $scope.list = new RenderableList data

    # RELOCATE to a host_env service.
    $scope.dispatch_action = (action) ->
      console.log "TODO dispatch #{action}"

      data =
        name: 'action'
        value: action
      url = "perform?op=send_data&data=#{encodeURIComponent(JSON.stringify data)}"
      window.location = url


    # actionUpdated = (defaultName, value) ->
    #   # send down to the hosting layer.
    #   data =
    #     name: defaultName
    #     value: value
    #   url = "perform?op=send_data&data=#{encodeURIComponent(JSON.stringify data)}"

    #   # $.get url
    #   # WORKAROUND doesn't hit the delegate method.
    #   window.location = url



angular.module('app')
  # an enableWhen has click enabled only when it's selected.
  # TODO refine interface.
  .directive 'enableWhen', (webbuddy)->
    restrict: 'A'
    link: (scope, elem, attrs)->
      elem.on 'click', (event) ->

        event.preventDefault()

        item = angular.element(elem).scope().detail_item

        if elem.parents('.stack').hasClass('selected')
          webbuddy.on_item_click item

        event


  .filter 'toArray', ->
    (obj)->
      if ! (obj instanceof Object)
        return obj;

      _.map obj, (val, key) ->
        Object.defineProperty(val, '$key', {__proto__: null, value: key})
