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
