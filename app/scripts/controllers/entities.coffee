'use strict'


angular.module('app').config ($sceDelegateProvider)->
  $sceDelegateProvider.resourceUrlWhitelist([
    # // Allow same origin resource loads.
    'self',
    # // Allow loading from our assets domain.  Notice the difference between * and **.
    'http://localhost:9292/**'])



angular.module('app')
  .controller 'EntitiesCtrl',
    ($scope, $location, $q, $sce, Restangular) ->
      
      Restangular.setBaseUrl("#{$location.protocol()}://#{$location.host()}:9292")
      
      ## data

      $scope.data = 
        app_enum: 
          Restangular.all('apps').getList()
            .$object
        app_selection: []

        target_enum:
          Restangular.all('targets').getList()
            .$object
        target_selection: []
        
        log: []


      ## view -> controller interface

      $scope.deploy = () ->
        # POST deployment request.
        Restangular.all('runs').post 
          apps: $scope.data.app_selection.map (e) -> e.id
          targets: $scope.data.target_selection.map (e) -> e.id

        .then (data) ->
          run_id = data.run_id

          status_url = "http://localhost:9292/resque/statuses/#{run_id}"
          $scope.log "Packaging / deployment request made. #{status_url}"

          $scope.data.status_url = status_url

      $scope.log = (msg) ->
        $scope.data.log.unshift "#{new Date()}: #{msg}"


      ## transformations

      $scope.status_url = ->
        $scope.data.status_url
        # $sce.getTrustedResourceUrl $scope.data.status_url
      
      $scope.description = (app)->
        app.id


      ## doit
      


