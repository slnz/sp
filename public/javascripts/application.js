$(function() {
	$('#submit_payment').live('click', function() {
		return false;
	});
});

function swapPayment(type) {
	$(".pay_view").hide();
	$('#pay_' + type).show();
}