$(function() {
	$.ajaxCount = 0;
	
	$('#projects_per_page').change(function() {
		params['projects_per_page'] = $(this).val();
		document.location = $(this).attr('rel') + '?' + $.param(params);
	});
	
	// Partnership Filter
	$("div.poptions li a").toggle(function () {
			$('#filter_all').removeClass("selected");
			$(this).addClass("selected");
		},function () {
			$(this).removeClass("selected");
			if($('div.poptions li a.selected').length == 0) $('#filter_all').addClass("selected");
		}
	);
	
  $('#mvmtselector').click(function(){
  	$('div#mvmtfilter').toggle();
  });

	$('#filter_all').click(function() {
		$(this).addClass("selected");
		$('[data-partner]').removeClass("selected");
	});
	
	$('#filter_button').click(function() {
		$(this).attr('disabled', true);
		filters = {}
		var partners = [];
		$('div.poptions li a.selected[data-partner]').each(function(i) {
			partners[i] = $(this).attr('data-partner');
		});
		if(partners.length > 0) filters['partners'] = partners;
		if($('#closed:checked')[0] != null) filters['closed'] = true;
		document.location = $(this).attr('rel') + '?' + $.param(filters);
			
	});
	// END Partnership Filter
	
	// Find as you type
	$('.search').keyup(function() {
		// Clear the other search fields
		$('.search').not(this).val('');
		param = $(this).attr('name');
		params[param] = $(this).val();
		$('#spinner_' + param).show();
		$.ajaxCount++;
		$.ajax({url: $(this).attr('rel') + '?' + $.param(params), dataType: 'script', complete: function() {
																																															$.ajaxCount--;
																																															if($.ajaxCount == 0) $('#spinner_' + param).hide();
																																														}});
	})
	// END Find as you type
	$("#tabs").tabs();
  $("#sp_project_start_date").datepicker();
  $("#sp_project_end_date").datepicker();
 
  $("#readmoreless").click(function() {
    $('#explain1').toggleClass('showall', 500);
    $(this).text($(this).text() == 'Read More' ? 'Read Less' : 'Read More');
  	return false;
 	});
});