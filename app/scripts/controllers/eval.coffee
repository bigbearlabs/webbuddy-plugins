'use strict'

# prototyping ruby evaluation.
angular.module('modulesApp')
  .controller 'EvalCtrl', ($scope, $route, $window, Restangular) ->

    # FIXME this shows all the interop warts.
    $window.webbuddy_data_updated = ->
      $scope.data.input = $window.webbuddy_data.input
      $scope.data.output = $window.webbuddy_data.output

      set_output $scope.data.input
      $scope.$apply()

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
