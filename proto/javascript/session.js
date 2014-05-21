$(document).ready(function() {
  // Setup drop down menu
  $('.dropdown-toggle').dropdown();
 
  // Fix input element click problem
  $('.dropdown-menu input, .dropdown-menu label').click(function(e) {
    e.stopPropagation();
  });
});