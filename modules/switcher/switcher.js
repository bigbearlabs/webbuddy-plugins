
// lay out using isotope.
var layout = function() {
  var $container = $('#container');
  $container.isotope({
    itemSelector: '.tool',
    layoutMode : 'cellsByRow',
    cellsByRow : {
       columnWidth: 300,
       rowHeight: 80
     }
  });
};

var setupNewAddressTool = function () {
  // set up new address tool.
  var $newAddressTool = $('#new-address-tool');
  $newAddressTool[0].activate = function () {
    // the activate function is protocol in this script indicating a user has activated a highlighted item.
    return function() {
      var $newAddressTool = $('#content #new-address-tool')
      
      // show all views necessary for activation TODO
      
      // other view actions: focus on the right view.
      $newAddressTool.children().forEach(function(child) {
        console.log("hi i'm" + child); 
      });

      // set up the submission handler
      $newAddressTool.find('.submit').click(function() {
        window.location = $newAddressTool.find('.address').get(0).value 
        // FIXME this doesn't jive
        // how to best call into the app?
      });
    };
  };
};

// carousels the selected item.
var carouselSelection = function () {
  var $selectedItem = $('#content .tool.selected');
  $selectedItem.removeClass('selected');
  var $itemToSelect = $selectedItem.next();
  if ($itemToSelect.length == 0) {
    $itemToSelect = $('#content .tool').first();
  };
  $itemToSelect.addClass('selected');
};

var selectFirstTool = function() {
  // select the first item
  $('#content .tool').first().addClass('selected')
};

var activateTool = function(toolId) {
  var $toolView = $("#" + toolId)
  // assert not nil TODO

  var view = $toolView.get(0);
  view.activate();
};

////

var addToList = function(item) {
  // clone the template
  $itemDiv = $('#stub-tool-id').clone();
  $itemDiv.removeClass('template');
  
  // fill in the attributes in the template
  $itemDiv.attr('id', item.id);
  $itemDiv.children('.name').text(item.name);

  // append to the list
  $('#container').isotope( 'insert', $itemDiv );
}

////

var getSelectedToolId = function() {
  var $selectedItem = $('#content .tool.selected');
  return $selectedItem.get(0).id;
};

////

var addStubTools = function() {
  addToList( {
    id: 'http://google.com',
    name: 'Google'
  });
  addToList( {
    id: 'http://pinterest.com',
    name: 'Pinterest'
  });
};

////

// post-load logic.
layout();
setupNewAddressTool();
