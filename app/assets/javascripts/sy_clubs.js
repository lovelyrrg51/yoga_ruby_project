$(document).on('turbolinks:load', function() {

  $("#sy_club_form").validate({
    errorPlacement: function (error, element) {
      (element.attr("name") == "sy_club[content_type][]") ? error.appendTo($(".sy_club_content_type_select_error")) : error.insertAfter(element);
    }
  });

  $('form#sy_club_form').submit(function(){
    var error = false
    _.find($("input[name*='sadhak_profile_id']"), function(ele){
      if(!$(ele).val().length){
        error = true;
      }
    });
    if(error){
      toastr.error("Please complete the Board Members Details.");
      return false;
    }
  });

  $('form#sy_club_reference_form').submit(function(){

    var element = _.find($("input[name*='[name]']"), function(ele){
      return $(ele).val() != ""
    })

    if (typeof element == "undefined" || (!$(element).length)){
      toastr.error("Please enter the Reference Names.");
      return false;
    }
    
  });

  $('form#sy_forum_register_form').submit(function(){

    if (!$('input#forum_register_ack_checkbox').is(':checked')) {
      $('input#forum_register_ack_checkbox').parents('div.CustomCheckbox.event_register_ack_div').siblings('span.forum_register_ack_checkbox_error_span').text('This field is required.');
      return false;
    }

  });

  $('form#sy_forum_register_form').validate({
    onkeyup: false,
    rules: {
      "event_order[guest_email]": { required: function () { return $("[name='event_order[guest_email]']").val() == ""; }, email: true },
    }
  });

  $(".syid-first-name-board-member-search").focusout(function(){

    var parDiv = $(this).closest('div.sy_club_user_role'), syid = parDiv.find("input[name*='syid']").val()
    var  oldSyid = parDiv.find("input[name*='syid']")[0].defaultValue, oldFirstName =  parDiv.find("input[name*='first_name']")[0].defaultValue
      , first_name = parDiv.find("input[name*='first_name']").val(), index = parDiv.data('index'), slug = $("input[type='hidden'][name='id']").val();
    
    if(syid.length && first_name.length){
      $.ajax({
        data: {
          "index": index,
          "syid": syid,
          "first_name": first_name,
          "slug": slug,
          noLoading: true
        },
        dataType: 'script',
        url: "/v1/forums/verify_board_member",
        success: function () { }
      });
    }

  });


  $('form#migrate_offline_forum_data').validate({
  	errorPlacement: function(error, element) {
        if (element.attr('name') == 'recipients') {
        	error.appendTo($('div.recipients-error'));
        }else if (element.attr('name') == 'forum_offline_data_file') {
        	error.appendTo($('div.forum_offline_data_file-error'));
        }
        else {
              error.insertAfter(element);
        }
      }
    }
	);

});

$(document).on('click', '#toggleForumStatusInput', function(){

    $('form#sy_club_form').trigger("reset");
    $('#forum_status_note_modal').modal('show');

    if($(this).is(':checked')){
        $('#forum_status_note_modal').find("input[name='sy_club[status]']").val("enabled");
    }else{
        $('#forum_status_note_modal').find("input[name='sy_club[status]']").val("disabled");
    }

});

$(document).on('hide.bs.modal', '#forum_status_note_modal', function() {
    $('#toggleForumStatusInput').prop('checked', !$('#toggleForumStatusInput').is(':checked'));
    $('#forum_status_note_modal').find("input[name='sy_club[status]']").val("");
});

$(document).on('hide.bs.modal', '#forum_status_update_note_modal', function() {
    var id = $("#forum_status_update_note_modal").find("form#sy_club_form").attr('action');
    var inputEl = $('input.updateForumStatusInput:checkbox[data-id = "'+id+'"]');
    inputEl.prop('checked', !inputEl.is(':checked'));
    $('#forum_status_update_note_modal').find("input[name='sy_club[status]']").val("");
});
$(document).on('turbolinks:load', function(){
    $('.sy_clubs_row input.updateForumStatusInput:checkbox').click(function(){
        $('form#sy_club_form').trigger("reset");
        var id = $(this).data('id');
        $('#forum_status_update_note_modal').modal('show').find("form#sy_club_form").attr('action', id );
        if ($(this).is(':checked')) {
            $('#forum_status_update_note_modal').find("input[name='sy_club[status]']").val("enabled");
        } else {
            $('#forum_status_update_note_modal').find("input[name='sy_club[status]']").val("disabled");
        }
    })
});
$(document).on("click", ".sy_club_basic_form_clear", function(){
  Turbolinks.visit(window.location.toString(), { action: 'replace' });
});