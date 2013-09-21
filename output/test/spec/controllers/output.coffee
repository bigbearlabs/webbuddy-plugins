'use strict'

describe 'Controller: OutputCtrl', () ->

  # load the controller's module
  beforeEach module 'modulesApp'

  OutputCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    OutputCtrl = $controller 'OutputCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
