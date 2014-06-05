# TODO factor out the matching algo, PoC switching to list.js or another fuzzy text match lib.


'use strict'

angular.module('app')
  .controller 'ListCtrl',
  (webbuddy, $scope, $window, $timeout, $q, Restangular, debounce ) ->
    # stub
    $scope.list = [ 'a', 'b', 'c' ]

# TODO relocate.
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
