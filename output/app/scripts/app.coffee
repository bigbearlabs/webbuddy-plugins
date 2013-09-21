'use strict'

angular.module('modulesApp',  ['restangular'])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/output.html',
        controller: 'OutputCtrl'
      .otherwise
        redirectTo: '/'
