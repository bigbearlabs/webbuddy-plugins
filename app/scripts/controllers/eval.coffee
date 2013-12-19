'use strict'

# prototyping ruby evaluation.
angular.module('modulesApp')
  .controller 'EvalCtrl', ($scope, Restangular, $route) ->

    # Restangular.setBaseUrl "data"  # interface with webbuddy-env.

    # Restangular.one('eval.json').get()
    # .then (data)->
    #   $scope.expression =
    #     eval: data.eval

    # # debug
    # $scope.debug =
    #   restangular: Restangular



    # TODO switch for js or ruby.
    # evaluate js.
    $scope.evaluate = (expr) ->
      try
        eval_result = eval(expr)

        # work around cyclic refs tripping up JSON.stringify
        eval_result = JSON.decycle eval_result

        $scope.obj = {}
        $scope.obj[expr] = eval_result
      catch e
        e


# used by js_obj.html.haml.
# TODO modularise cleanly
angular.module('modulesApp')
  .controller 'ObjTreeCtrl', ($scope) ->

    $scope.obj_keys = (val)->
      return [] if val is null

      if typeof val is 'object'
        # console.log "val: #{val}, type: #{typeof val}"
        Object.keys val
      else
        []

    # quick-hack terminal transformation to ensure recursive rendering succeeds.
    $scope.to_displayable = (val)->
      return '<null>' if val is null

      switch typeof(val)
        when 'object'
          ''
        when 'function'
          String(val)
        # TODO arrays, other types falling under js quirks
        else
          val
