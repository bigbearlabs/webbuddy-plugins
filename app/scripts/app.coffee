'use strict'

angular.module('modulesApp',  ['restangular', 'iso.directives'])
  .config ($routeProvider) ->
    $routeProvider

      .when '/filtering',
        templateUrl: 'views/filtering.html',
        controller: 'FilteringCtrl'

      .when '/eval',
        templateUrl: 'views/eval.html',
        controller: 'EvalCtrl'

      .otherwise
        redirectTo: '/'
