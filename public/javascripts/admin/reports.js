$(function() {
  $('.focus_name').click(function() {
    $(this).next().toggle();  
    $(this).next().next().toggle();  
  });
  $('.pd_type').click(function() {
    $(this).next('div').toggle();  
  });

});
