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
});