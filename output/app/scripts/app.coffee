'use strict'

angular.module('modulesApp',  ['restangular', 'iso.directives'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/output.html',
        controller: 'OutputCtrl'
      .when '/filtering',
        templateUrl: 'views/filtering.html',
        controller: 'FilteringCtrl'
      .otherwise
        redirectTo: '/'
