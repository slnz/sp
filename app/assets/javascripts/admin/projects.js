$(function() {
  $.ajaxCount = 0;

  $('.delete_question').click(function() {
    var parent = $(this).closest('div');
    $('input[type=text]').val('');
    parent.closest('div.multifield').fadeOut();
    return false;
  });

  $('#projects_per_page').change(function() {
    params['projects_per_page'] = $(this).val();
    document.location = $(this).attr('rel') + '?' + $.param(params);
  });

  // Partnership Filter
  $(document).on('click', "div.poptions li a", function() {
      if($(this).hasClass("selected")) {
        $(this).removeClass("selected");
        if($('div.poptions li a.selected').length == 0) {
          $('#filter_all').addClass("selected");
        }
      } else {
        $('#filter_all').removeClass("selected");
        $(this).addClass("selected");
      }
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
    filters = {};
    var partners = [];
    $('div.poptions li a.selected[data-partner]').each(function(i) {
      partners[i] = $(this).attr('data-partner');
    });
    if(partners.length > 0) { filters['partners'] = partners; }
    if($('#closed:checked')[0] != null) { filters['closed'] = true; }
    document.location = $(this).attr('rel') + '?' + $.param(filters);

  });
  // END Partnership Filter

  // Find as you type
  var search_prompt = 'Type here to filter';
  $('#dashboardlist .search').each(function() {
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
      $('#dashboardlist .search').not(this).val('');
      params = {closed: params['closed']}
      param = $(this).attr('name');
      params[param] = $(this).val();
      $('#spinner_' + param).show();
      $.ajaxCount++;
      $.ajax({url: $(this).attr('rel') + '?' + $.param(params), dataType: 'script', complete: function() {
        $.ajaxCount--;
        if($.ajaxCount == 0) { $('#spinner_' + param).hide(); }
      }});
    });
  // END Find as you type

  // Row hover actions
  $(document).on('mouseenter', '.project_row', function() {
    $('.rollovershow, .rollovershow_nostyle', this).show();
  }).on('mouseleave', '.project_row', function() {
    $('.rollovershow, .rollovershow_nostyle', this).hide();
  });
  // END row hover actions

  // Edit checkboxes
  $(".checkvertical input[type=checkbox]").click(function() {
    $(this).closest('div').toggleClass('selected');
  });
  // END Edit checkboxes

  // Person Info
  $(document).on('click', "a.person", function() {
    id = $(this).attr('data-id');
    proj = $(this).attr('data-project-id');
    year = $(this).attr('data-year');
    if(proj == null || proj == ''){
      proj = 0;
    }
    if (id != null) {
      name = $(this).html();
      dom = 'leader_details' + id;
      if ($('#' + dom)[0] == null) {
        $('body').append('<div id="' + dom + '" title="' + name + '"><img alt="Spinner" class="spinner" id="spinner_' + id + '" src="/assets/spinner.gif" style="" /></div>');
        $.ajax({dataType: 'script',
          type:'GET',
          url: '/admin/people/' + id + '?project_id=' + proj + '&year=' + year
        });
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
          $("#sp_application_start_date").datepicker();
          $("#sp_application_end_date").datepicker();
          $('#leader_details' + id).dialog('option',{height:720, buttons: {}});
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
          };
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

  // $(document).on('click', '.edit_person_link', function() {
  //
  // 	return false
  // });

  $(document).on('click', '.cancel_edit_person_link', function() {
    id = $(this).attr('data-id');
    $('#leader_details' + id).dialog('close');
    return false;
  });

  $(document).on('ajax:loading', '#update_person_form', function() {
    $('#person_' + id + '_form').html('<img src="/images/spinner.gif" />');
  });
  // END Leader Info

  // Edit Leader
  $(document).on('click', "a.edit-leader", function() {
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
      title: name,
      resizable: false,
      height:600,
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
        dataType: 'html',
        type: 'POST',
        success: function(data) {
          $('#leader_search_results').html(data);
          $("#leader_search_results").show();
        },
        complete: function(jqXHR, textStatus) {
          $('#spinner_leader_search').hide();
        }
      });
      response([]);
    }
  });

  // Update leader
  $(document).on('click', 'a.new_leader', function() {
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
      message += 'You need to put in at least one email address to send this email to.<br />';
    }
    if ($.trim($('#subject').val()) == '') {
      message += 'Please provide a subject for your email.<br />';
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

  $("#sp_application_start_date").datepicker();
  $("#sp_application_end_date").datepicker();

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

  $('#sp_project_use_provided_application').change(function() {
    if ($(this).val() == 'true') {
      $('#application_questions').show();
    } else {
      $('#application_questions').hide();
    }
  });
});
