'use strict'

angular.module('modulesApp',  [
  'ngRoute',
  'restangular',
  # 'iso.directives',
  'pasvaz.bindonce',
  "xeditable"
])
  .config ($routeProvider) ->
    $routeProvider

      .when '/filtering',
        templateUrl: 'views/filtering.html',
        controller: 'FilteringCtrl'

      .when '/eval',
        templateUrl: 'views/eval.html',
        controller: 'EvalCtrl'

      .otherwise
        redirectTo: '/filtering'
