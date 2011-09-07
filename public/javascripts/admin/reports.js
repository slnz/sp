$(function() {
  $('.focus_name').click(function() {
    $(this).next().toggle();  
    $(this).next().next().toggle();  
  });
  $('.pd_type').click(function() {
    //$(this).next('div').toggle();   /* doesn't seem to find the next div for some reason, after I added the A... */
    $(this).next().next().toggle();  
  });

});
