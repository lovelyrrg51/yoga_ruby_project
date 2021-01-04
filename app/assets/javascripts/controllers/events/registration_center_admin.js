// REGISTRATION CENTER ADMIN JS
$(document).on('turbolinks:load', function() {

    $('button.btn.btn-info.event-rc-member-add-button').click(function(){

      $(this).parents('div.pannel-btn').siblings('div.prelative').find('div.add-rc-member-form-div').removeClass('overlay-active');

    });

    $('button.event-rcmember-form-add-button').click(function(){

      var form = $("form#add-event-rcmembers-form"), syid = $("input[name='search-field-syid']").val(), first_name = $("input[name='search-field-first_name']").val(), error = false;
      $('label#search-field-syid-error-label').text('');
      $('label#search-field-first_name-error-label').text('');
      
      if (syid.length == 0)
      {
        $('label#search-field-syid-error-label').text('This field is required.');
        error = true;
      }
      if (first_name.length == 0)
      {
        $('label#search-field-first_name-error-label').text('This field is required.');
        error = true;
      }
      if(!error)
      {

        form.html('');
        form.append('<input type="hidden" value=' + syid + ' name="rc_user[syid]"/>')
            .append('<input type="hidden" value=' + first_name + ' name="rc_user[first_name]"/>')
            .submit();
        $("input[name='search-field-syid']").val('');
        $("input[name='search-field-first_name']").val('');
        $('div.overlapping.add-rc-member-form-div').addClass('overlay-active');     

      }

    });

});

 function remove_event_rcmember(i)
    {
      
      var e = window.event, srcElementQ = $(e.srcElement);

      $(srcElementQ).closest("tr").remove();

      if($('div.temp-added-event-rcmembers-div').find('table').find('tbody').find('tr').length == 0)
      {
        $('div.temp-added-event-rcmembers-div').addClass('hidden');
      }

    }

  // END REGISTRATION CENTER ADMIN JS