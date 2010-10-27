$(function() {
	// Payment submission
	$('.submit_payment').live('click', function() {
		var form = $(this).closest('form');
		$.ajax({url: $(this).attr('data-url'), data: form.serializeArray(), type: 'POST', dataType:'script',
                       beforeSend: function (xhr) {
                           $('body').trigger('ajax:loading', xhr);
                       },
                       complete: function (xhr) {
                           $('body').trigger('ajax:complete', xhr);
                       },
                       error: function (xhr, status, error) {
                           $('body').trigger('ajax:failure', [xhr, status, error]);
                       }
						})
		return false;
	});
});

function swapPayment(type) {
	$(".pay_view").hide();
	$('#pay_' + type).show();
}