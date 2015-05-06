'use strict'


angular.module('app').config ($sceDelegateProvider)->
  $sceDelegateProvider.resourceUrlWhitelist([
    # // Allow same origin resource loads.
    'self',
    # // Allow loading from our assets domain.  Notice the difference between * and **.
    'http://localhost:9292/**'])


# define enum and selection properties for each collection requested to be sourced from server..
angular.module('app')
  .service 'sync_data', (Restangular) ->
    (path_on_scope, collection_names)->
      new_properties = collection_names.map (collection_name) ->
        delta = {}
        Restangular.all("#{collection_name}s").getList()
        .then (list) ->
          delta["#{collection_name}_enum"] = list

          delta["#{collection_name}_selection"] = []
        
          _.merge path_on_scope, delta


angular.module('app')
  .controller 'EntitiesCtrl',
    ($scope, $location, $q, $sce, Restangular, sync_data) ->
      
      Restangular.setBaseUrl("#{$location.protocol()}://#{$location.host()}:9292")
      
      ## data sourced from API using sync_data service.
      $scope.data = 
        log: []
        
      sync_data $scope.data, [ 'app', 'target' ]


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
      
