function displayWarning() {
	if ($('#event').val() == "decline") {
  	alert("WARNING: Are you sure you want to decline this student?\n\n" +
    "• Declined = Applicant has been evaluated and found not acceptable to participate in ANY Student Life project, not even a one-week project. Few if any students should ever be marked this way.\n\n" +
    "• Withdrawn = Applicant has requested their application to be withdrawn because they are no longer going on project. Their application will still be in the SP Tool and can be un-withdrawn if need be.\n\n" +
    "If you have questions about this, please email projects@studentlife.org.nz");
  }
}

$(function() {
	$('.calc input').click(function() {
		var row = $(this).closest('tr.question');
		var value = $(this).val();
		$('.score', row).html(Number($('.weight', 	row).html() * value));
		var total = 0;
		$('.score').each(function() {
			total += Number($(this).html());
		});
		$('#total_score span').html(total);
	});

	$(document).on('click', '.evaluation_page_link', function() {
		$('#evalcontent').html('<img src="/images/spinner.gif" class="spinner" />');
	});

	$('.print_button').click(function() {
		$("#print_options").dialog({
			resizable: false,
			height:240,
			modal: true,
			buttons: {
				Cancel: function() {
					$(this).dialog('close');
				},
				Print: function() {
					$(this).dialog('close');
					$('#print-options-form').submit();
				}
			}
		});
	});
});
