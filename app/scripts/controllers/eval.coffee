'use strict'

# prototyping ruby evaluation.
angular.module('app')
  .controller 'EvalCtrl',
  ($scope, $route, $window, Restangular) ->

    set_output = (expr, output) ->
      $scope.obj = {}  # interface with ObjTreeCtrl
      $scope.obj[expr] = output

    $scope.is_object = (obj) ->
      typeof(obj) == 'object'



    # evaluate js.
    $scope.evaluate = (expr) ->
      try
        eval_result = $scope.do_eval(expr)

        # work around cyclic refs tripping up JSON.stringify
        eval_result = JSON.decycle eval_result

        set_output expr, eval_result
      catch e
        e


    # env-specific.

    $scope.do_eval = (expr)->
      # javascript version.
      eval(expr)


    ## dev

    $scope.fetch_data = ->
      Restangular.setBaseUrl "data"
      Restangular.one('eval.json').get()
      .then (data)->
        $scope.data = data
        $scope.evaluate data.input


    # debug
    $scope.debug =
      restangular: Restangular


    $scope.fetch_data()

# used by obj_tree.html.haml.
# TODO modularise cleanly
angular.module('app')
  .controller 'ObjTreeCtrl', ($scope) ->

    $scope.obj_keys = (obj)->
      return [] if obj is null

      if typeof obj is 'object'
        # console.log "obj: #{obj}, type: #{typeof obj}"
        Object.keys obj
      else
        []

    # quick-hack terminal transformation to ensure recursive rendering succeeds.
    $scope.to_displayable = (val)->
      return '<null>' if val is null

      switch typeof(val)
        when 'object'
          'object with the following properties:'
        when 'function'
          val.toString()
        # TODO arrays, other types falling under js quirks
        else
          val
