'use strict'


angular.module('app')

  .controller 'TimerMenuCtrl',
    ($scope, $route, $location, $window, $timeout, $q, host_env, Restangular, debounce ) ->


      # stub
      $scope.menu_data = [
      #   # timer operation. immature

      #   new RenderableItem
      #     description: 'Reset'
      # ,
      #   new RenderableItem
      #     description: '---'
      # ,

        new RenderableItem
          description: 'Help'
          on_select: ->
            # TODO load help.
      ,
        new RenderableItem
          description: 'About'
          on_select: ->
            # TODO show menu.
          menu: [
            new RenderableList
              description: 'News'
          ,
            new RenderableItem
              description: 'View in App Store'
          ,
            new RenderableItem
              description: 'Lovingly crafted by Big Bear Labs.'
          ,
          ]
      ,
        new RenderableItem
          description: 'More from Big Bear Labs'
          on_select: ->
            # TODO load company page.
      ,
      ]


      ## doit

      # request data for id.
      id = $route.current.params.id

      # throw "id must not be nil" unless id?  # DEBUG
      id ||= 'stub'

      $q.when(host_env.get id)
      .then (data) ->
        items = _.keys(data).map (k)->
          new RenderableItem
            description: data[k]
            template: 'editable-text'

        $scope.entity_data = items
        # $scope.$apply()



  .directive 'contenteditable', ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs, ngModel) ->
      read = ->
        ngModel.$setViewValue(element.html())

      ngModel.$render = ->
        element.html(ngModel.$viewValue || "")

      element.bind "blur keyup change", ->
        scope.$apply read

