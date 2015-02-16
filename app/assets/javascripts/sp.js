function swapPayment(type) {
  $(".pay_view").hide();
  $('#pay_' + type).show();
}

function searchCampuses(state_el_id, campus_el_id, application_id) {
  $('#spinner_' + campus_el_id).show();
  $.ajax({url: '/campuses/search',
         dataType:'script',
         data: {state: $('#' + state_el_id).val(), dom_id: campus_el_id, id: application_id},
         type: 'POST'
  });
}

$(function() {
  $(document).on('keydown', '#payment_staff_first, #payment_staff_last', function(e) {
    //debugger;
    if (e.which == 13) {
      console.log('staff_search click');
      $('#staff_search').trigger('click');
      return false;
    }
  });

  // Payment submission
  $(document).on('click', '.submit_payment', function() {
    var form = $(this).closest('form');
    var number = $('#payment_card_number', form).val();

    // We only want to validate and encrypt if we have a new number.
    // After a failed form submit, the number will contain xxxxxxxxxxxx
    pad_str = 'xxxxxxxxxxxx'
    if (number.indexOf(pad_str) != 0) {
      var validationError = ccp.validateCardNumber(number);

      if (validationError) {
        alert(validationError);
        return false;
      } else {
        var abbreviated_number = ccp.getAbbreviatedNumber(number);
        var encrypted_number = ccp.encrypt(number);
        $('#payment_encrypted_card_number', form).val(encrypted_number);
        $('#payment_card_number', form).val(pad_str + abbreviated_number);
        var encrypted_code = ccp.encrypt($('#security_code').val());
        $('#payment_encrypted_security_code', form).val(encrypted_code);
      }
    }
    $this = $(this);
    $.ajax({url: $(this).attr('data-url'), data: form.serializeArray(), type: 'POST', dataType:'script',
           beforeSend: function (xhr) {
             $('body').trigger('ajax:loading', xhr);
             if ($this.data('disable-with') !== null) {
               $this.attr('disabled','disabled');
               $this.data('enabled-text', $(this).html());
               $this.attr('value', $this.data('disable-with'));
             }
           },
           complete: function (xhr) {
             $('body').trigger('ajax:complete', xhr);
             $this.removeAttr('disabled');
             $this.attr('value', $this.data('enabled-text'));
           },
           error: function (xhr, status, error) {
             $('body').trigger('ajax:failure', [xhr, status, error]);
             $this.removeAttribute('disabled');
             $this.attr('value', $this.data('enabled-text'));
           }
    });
    return false;
  });
});
