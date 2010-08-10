$(function() {
	$('#projects_per_page').change(function() {
		params['projects_per_page'] = $(this).val();
		document.location = $(this).attr('rel') + '?' + $.param(params);
	});
});