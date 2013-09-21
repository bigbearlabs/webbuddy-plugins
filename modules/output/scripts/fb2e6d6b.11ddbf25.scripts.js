(function () {
  'use strict';
  angular.module('modulesApp', ['restangular']).config([
    '$routeProvider',
    function (a) {
      return a.when('/', {
        templateUrl: 'views/output.html',
        controller: 'OutputCtrl'
      }).when('/filtering', {
        templateUrl: 'views/filtering.html',
        controller: 'FilteringCtrl'
      }).otherwise({ redirectTo: '/' });
    }
  ]);
}.call(this), function () {
  'use strict';
  angular.module('modulesApp').controller('OutputCtrl', [
    '$scope',
    'Restangular',
    '$route',
    function (a, b, c) {
      return b.setBaseUrl('data'), b.one('output.json').get().then(function (b) {
        return a.expression = { output: b.output };
      }), a.debug = {
        restangular: b,
        moduleName: moduleName,
        route: c
      };
    }
  ]);
}.call(this), function () {
  'use strict';
  angular.module('modulesApp').controller('FilteringCtrl', [
    '$scope',
    function (a) {
      return a.partials = { collection: 'views/collection.html' }, a.input = 'a test search', a.data = window.data;
    }
  ]), window.data = {
    suggestions: [
      'suggestion 1',
      'suggestion 2'
    ],
    searches: [
      'previous search 1',
      'previous search 2'
    ],
    pages: [
      'matching page 1',
      'matching page 2'
    ]
  };
}.call(this));