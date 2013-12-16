'use strict'

describe 'Controller: FilteringCtrl', () ->

  # load the controller's module
  beforeEach module 'modulesApp'

  FilteringCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    FilteringCtrl = $controller 'FilteringCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
