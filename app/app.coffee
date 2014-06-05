'use strict'

# 'use strict'

# Declare app level module which depends on filters, and services
App = angular.module('app', [
  'ngCookies'
  'ngResource'
  'ngRoute'
  'partials'
  'restangular'
  'rt.debounce'
  # 'ngAnimate'
  'xeditable'

  'pasvaz.bindonce'
  'wu.masonry'
  'rn-lazy'
])

App.config(
  ($routeProvider, $locationProvider) ->

    $routeProvider

      .when('/menu', {templateUrl: 'views/menu.html'})
      .when('/eval', {templateUrl: 'views/eval.html'})
      .when('/action', {templateUrl: 'views/action.html'})

      # Catch all
      .otherwise({redirectTo: '/menu'})

    # Without server side support html5 must be disabled. -- from BNWH template.
    # $locationProvider.html5Mode(false)

)
