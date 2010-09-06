$(function() {
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
		$(this).callRemote();
    e.preventDefault();
	});
});