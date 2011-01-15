$(function() {
	$('.search_show_all_link').live('click', function() {
		$('#spinner_leader_search').show();
		$('#show_all').val('true')
		var form = $('#leader_search_form')
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
		return false;
	});
	
	$('.inlinetip a.prompt').click(function() {
		$(this).hide();
		$(this).next('.tip').show();
		return false;
	});

	$('.inlinetip a.hidetip').click(function() {
		div = $(this).closest('.inlinetip');
		$('.tip', div).hide();
		$('.prompt', div).show();
		return false;
	});
	
	$("#tabs").tabs({
		ajaxOptions: {
			error: function(xhr, status, index, anchor) {
				$(anchor.hash).html("Couldn't load this tab. We'll try to fix this as soon as possible.");
			}
		},
		cache: true,
		spinner: '<img src="/images/spinner_dark.gif" />',
		load: function() {
			$('.spinner').html('');
		}
	});
	$('.pagination a').live('click', function(e) {
		$(this).html('<img src="/images/spinner.gif" />');
		$(this).callRemote();
    e.preventDefault();
	});
	$('tr:odd').addClass('odd');
});