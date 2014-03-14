'use strict'

# prototyping ruby evaluation.
angular.module('app')
  .controller 'ActionCtrl',
  ($scope, $route, $window, Restangular) ->

    action =
      name: 'stub action'
      href: 'http://stub-url'

    $scope.obj = action

    #== remnants of EvalCtrl.

    # TODO switch for js or ruby.
    # evaluate js.
    $scope.evaluate = (expr) ->
      try
        eval_result = eval(expr)

        # work around cyclic refs tripping up JSON.stringify
        eval_result = JSON.decycle eval_result

        set_output expr, eval_result
      catch e
        e

    set_output = (expr, output) ->
      $scope.obj = {}  # interface with ObjTreeCtrl
      $scope.obj[expr] = output


    ## dev

    $scope.fetch_stub_data = ->
      Restangular.setBaseUrl "data"
      Restangular.one('eval.json').get()
      .then (data)->
        $scope.data.input =
          eval: data.eval

    # debug
    $scope.debug =
      restangular: Restangular




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
          ''
        when 'function'
          String(val)
        # TODO arrays, other types falling under js quirks
        else
          val
