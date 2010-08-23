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
		$(this).toggleClass('active');
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
	var search_prompt = 'Type here to filter';
	$('.search').each(function() {
		if ($(this).val() == '') {
			$(this).val(search_prompt);
			$(this).addClass('prompt');
		}
	}).focus(function() {
		if ($(this).val() == search_prompt) {
			$(this).val('');
			$(this).removeClass('prompt');
		}
	}).blur(function() {
		if ($(this).val() == '') {
			$(this).val(search_prompt);
			$(this).addClass('prompt');
		}
	}).keyup(function() {
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
	
	// Row hover actions
	$('.project_row').live('mouseenter', function() {
		$('.rollovershow', this).show();
	}).live('mouseleave',function() {
		$('.rollovershow', this).hide();
	});
	// END row hover actions
	
	// Edit checkboxes
	$(".checkvertical input[type=checkbox]").click(function() {
		$(this).closest('div').toggleClass('selected');
	})
	// END Edit checkboxes
	
	// Leader Info
	$("a.person").live('click', function() {
		id = $(this).attr('data-id');
		if (id != null) {
			name = $(this).html();
			dom = 'leader_details' + id;
			if ($('#' + dom)[0] == null) {
				$('body').append('<div id="' + dom + '" title="' + name + '"><img alt="Spinner" class="spinner" id="spinner_' + id + '" src="/images/spinner.gif" style="" /></div>');
				$.ajax({dataType: 'script',
								type:'GET', 
								url: '/admin/leaders/' + id
				 })
			}
			$("#" + dom).dialog({
				resizable: false,
				height:300,
				width:400,
				modal: true,
				buttons: {
					Close: function() {
						$(this).dialog('close');
					}
				}
			});
			return false;
		}
	});
	
	$('td:not(.sidebar) > .leader_cell').live('mouseenter', function() {
		$('.buttons', this).show();
	}).live('mouseleave', function() {
		$('.buttons', this).hide();
	});
	// END Leader Info
	
	// Edit Leader
	$("a.edit-leader").live('click', function() {
		id = $(this).attr('data-id');
		name = $(this).attr('data-name');
		el = $('#leader_search');
		el.attr('title', name);
		form = $('#leader_search_form');
		$('#leader_search_project_id').val($(this).attr('data-id'));
		$('#leader_search_type').val($(this).attr('data-leader'));
		el.dialog({
			resizable: false,
			height:423,
			width:400,
			modal: true,
			buttons: {
				Cancel: function() {
					$(this).dialog('destroy');
				}
			}
		});
		return false;
	});
	
	// Search for new leader
	$('#leader_search_name').keyup(function() {
		$('#spinner_leader_search').show();
		form = $('#leader_search_form');
		$.ajaxCount++;
		$.ajax({url: form.attr('action'), 
						data: form.serialize(), 
						dataType: 'script', 
						type: 'POST',
						success: function(data) {
							$('#leader_search_results').html(data);
						},
						complete: function() {
							$.ajaxCount--;
							if($.ajaxCount == 0) $('#spinner_leader_search').hide();
						}});
	});
	
	// Update leader
	$('a.new_leader').live('click', function() {
		$('#leader_search_name').val('');
		$('#leader_search_person_id').val($(this).attr('data-id'));
		form = $('#create_leader_form');
		$.ajax({url: form.attr('action'), 
						data: form.serialize(), 
						dataType: 'script', 
						type: 'POST'
						});
		$('#leader_search_results').html('<img src="/images/spinner.gif" />')
		return false;
	});
	// END Edit Leader
	
	$('.sidebar .buttons').css('display', 'inline');
	
	$("#tabs").tabs();
  $("#sp_project_start_date").datepicker();
  $("#sp_project_end_date").datepicker();
 
  $("#readmoreless").click(function() {
    $('#' + $(this).attr('rel')).toggleClass('showall', 500);
    $(this).text($(this).text() == 'Read More' ? 'Read Less' : 'Read More');
  	return false;
 	});
});