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
	
	// Person Info
	$("a.person").live('click', function() {
		id = $(this).attr('data-id');
		if (id != null) {
			name = $(this).html();
			dom = 'leader_details' + id;
			if ($('#' + dom)[0] == null) {
				$('body').append('<div id="' + dom + '" title="' + name + '"><img alt="Spinner" class="spinner" id="spinner_' + id + '" src="/images/spinner.gif" style="" /></div>');
				$.ajax({dataType: 'script',
								type:'GET', 
								url: '/admin/people/' + id
				 })
			}
			$('#person_' + id + '_form').hide();
			$('#person_' + id + '_info').show();
			var buttons = {
					Close: function() {
						$(this).dialog('close');
					},
					'Edit information': function() {
						$('#person_' + id + '_info').hide();
						$('#person_' + id + '_form').show();
					  $('#leader_details' + id).dialog('option',{height:520, buttons: {}})
					}
				};
			// If this is a leader, provide the option to change the leader
			var leader_link = $(this).closest('.leader_cell').find('.edit-leader');
			if (leader_link[0] != null) {
				var project_id = leader_link.attr('data-id');
				var leader = leader_link.attr('data-leader');
				if ( project_id && leader ) {
					buttons['Change Leader'] = function() {
						$(this).dialog('close');
						$('#edit_leader_' + project_id + leader).click();
					}
				}
			}
			$("#" + dom).dialog({
				resizable: false,
				height:300,
				width:400,
				modal: true,
				buttons: buttons
			});
			return false;
		}
	});
	
	// $('.edit_person_link').live('click', function() {
	// 
	// 	return false
	// });
	
	$('.cancel_edit_person_link').live('click', function() {
		id = $(this).attr('data-id');
	  $('#leader_details' + id).dialog('close');
		return false
	});
	
	$('#update_person_form').live('ajax:loading', function() {
		$('#person_' + id + '_form').html('<img src="/images/spinner.gif" />')
	});
	// END Leader Info
	
	$('td:not(.sidebar) > .leader_cell').live('mouseenter', function() {
		$('.buttons', this).show();
	}).live('mouseleave', function() {
		$('.buttons', this).hide();
	});
	
	// Edit Leader
	$("a.edit-leader").live('click', function() {
		id = $(this).attr('data-id');
		name = $(this).attr('data-name');
  	$('#add_leader_form').hide();
		$('#leader_search_form').show();
		$('#leader_search_name').val('');
	  $("#leader_search_results").hide();
		el = $('#leader_search');
		el.attr('title', name);
		form = $('#leader_search_form');
		$('#leader_search_project_id').val(id);
		$('#leader_search_type').val($(this).attr('data-leader'));
		el.dialog({
			resizable: false,
			height:427,
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
	
	$('#leader_search_name').autocomplete({
	  source: function(request, response) {
			// var term = request.term;
			$('#spinner_leader_search').show();
			$.ajax({url: form.attr('action'), 
				data: form.serialize(), 
				dataType: 'script', 
				type: 'POST',
				success: function(data) {
					$('#leader_search_results').html(data);
				  $("#leader_search_results").show();
				},
				complete: function() {$('#spinner_leader_search').hide();}
			});
			response([]);
		}
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
		$('#leader_search_results').html('<img src="/images/spinner.gif" />');
		return false;
	});
	// END Edit Leader
	
	// Add new person as leader
	$('#create_leader_form').bind('ajax:before', function() {
		$('#spinner_leader_add').show();
	});
	// END Add new person as leader
	
	// Send project email
	$('#email_form').submit(function() {
		var message = '';
		if ($.trim($('#to').val()) == '') {
			message += 'You need to put in at least one email address to send this email to.<br />'
		}
		if ($.trim($('#subject').val()) == '') {
			message += 'Please provide a subject for your email.<br />'
		}
		if (message != '') {
			$('#dialog-confirm').attr('title', 'Slow down :)');
			$('#dialog-confirm-message').html(message);
			$("#dialog-confirm").dialog({
				modal: true,
				buttons: {
					Ok: function() {
						$(this).dialog('close');
					}
				}
			});
			return false;
		} 
	});
	
	$('#changeyear').click(function() {
		$('#year_list').toggle();
		return false;
	});
	
  $("#sp_project_start_date").datepicker();
  $("#sp_project_end_date").datepicker();
 
  $("#readmoreless").click(function() {
    $('#' + $(this).attr('rel')).toggleClass('showall', 500);
    $(this).text($(this).text() == 'Read More' ? 'Read Less' : 'Read More');
  	return false;
 	});

	$('#group').change(function() {
		$('#to').val(emails[$('#group').val()]);
		if ($.trim($('#to').val()) == '') {
			$('#dialog-confirm').attr('title', 'Check your project year');
			var year = $('#changeyear').html();
			$('#dialog-confirm-message').html("There aren't any people in the group you selected for the " + year + " project year. Try choosing a different year from the dropdown, or manually enter some email addresses.");
			$("#dialog-confirm").dialog({
				modal: true,
				buttons: {
					Ok: function() {
						$(this).dialog('close');
					}
				}
			});
		}
	}); 

});