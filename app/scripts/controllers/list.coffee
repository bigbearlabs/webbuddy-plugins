'use strict'

class RenderableList
  constructor: (@items = []) ->

  add: (item) ->
    @items.push item

  items: -> @items  # sadly we must expose this for ng-repeat.

  # TODO remove(item)
  # TODO order(order_spec)
  # TODO filter(filter_spec)
  # TODO move(item)


class RenderableItem
  constructor: (props) ->
    for k, v of props
      @[k] = v

  template: 'basic-text'

  on_select: =>
    console.log "TODO impl on_select for #{JSON.stringify @}"

  edit_done: ->
    console.log "TODO done editing."



angular.module('app')

  .directive 'list', ->
    restrict: 'E'
    templateUrl: 'views/list.html'
    scope:
      data: '='
    controller: ($scope, $window, $timeout, $q, Restangular, debounce ) ->

      $scope.list = new RenderableList $scope.data
      $scope.$watch 'data', (new_val, old_val)->
        unless new_val == old_val
          $scope.list = new RenderableList new_val


      $scope.select = (item) ->
        item.on_select()

      $scope.edit_done = (item) ->
        host_env.update item.id,
          description: item.description



