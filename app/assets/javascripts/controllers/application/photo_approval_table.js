// Photo Approval Panal

//Status drop-down selection handler
$(document).on('click', '#photo_approval_select_profiles', function(){
  var checked = $(this).prop('checked');
  photoApprovalProfilesSelectOpertaions(current_filter, checked);
});

//Individual checkbox selection handler
$(document).on('click', '.rails_photo_approval_sadhak_select_checkbox', function(){
  $('button.rails_photo_approval_selected_profiles_action').prop('disabled', !($('.rails_photo_approval_sadhak_select_checkbox:checked').length > 1));

  var selectAllCheckbox = $('#photo_approval_select_profiles'),
      checked = $(this).prop('checked');

  if(selectAllCheckbox.prop('checked') && !checked){
    selectAllCheckbox.prop('checked', false);
  }
});


//Status selection processor
var current_filter = 'all';
var statuses = ['all', 'pending', 'approved', 'rejected', 'not_available'];
function photoApprovalProfilesSelectOpertaions(type, checked) {
  var profileCheckboxes = $(".rails_photo_approval_sadhak_select_checkbox"),
    selectAllCheckbox = $('#photo_approval_select_profiles'),
    switchAbleDivs = $('.rails_photo_approval_switch_div_class'),
    contentTable = $('.rails_photo_approval_content_table'),
    src = $(window.event.srcElement);
    
  if (src.hasClass('active')) return;

  src.parents('ul.list-unstyled').find('li').removeClass('active');

  src.closest('div.dropdown-menu.dropdownCntrl').siblings('button.btn.boxdrop-btn').find('span:first').html(src.html());

  src.parent().addClass('active');

  profileCheckboxes.prop('checked', false);
  selectAllCheckbox.prop('checked', !!checked);
  selectAllCheckbox.prop('disabled', false);
  contentTable.show();
  switchAbleDivs.hide();
  current_filter = type;

  if(type === 'all'){
    $.each(statuses, function(index, status){
      $('.photo_approval_sadhak_profile_row_'+status).show();
    });

    profileCheckboxes.prop('checked', checked);
  } else {
    $.each(statuses, function(index, status){
      $('.photo_approval_sadhak_profile_row_'+status)[type !== status?'hide': 'show']();
    });

    if ($('.photo_approval_sadhak_profile_row_'+type).length == 0) {
      switchAbleDivs.show();
      contentTable.hide();
      selectAllCheckbox.prop('disabled', true);
    }

    if (type === 'pending') {
      profileCheckboxes.prop('checked', checked);
    } else {
      selectAllCheckbox.prop('disabled', true);
    }
  }

  // Enable disable approve selected and reject selected buttons
  if ($('.rails_photo_approval_sadhak_select_checkbox:checked').length > 1 && ['all', 'pending'].indexOf(type) >= 0) {
    $('button.rails_photo_approval_selected_profiles_action').prop('disabled', false);
  } else {
    $('button.rails_photo_approval_selected_profiles_action').prop('disabled', true);
  }
}

//Approve & Reject selected profiles
function approveRejectSelectedProfiles(action) {

  var form = $("form#photo_approval_approve_reject_selected_profiles"), selectedProfileIds = [];

  form.attr('method', "post");
  form.attr('action', "/v1/sadhak_profiles/selected/profile_photo/"+ action);

  $.each($('.rails_photo_approval_sadhak_select_checkbox:checked'), function(i, row){
    selectedProfileIds.push($(row).attr('data-sadhak-profile-id'));
  });

  if (selectedProfileIds.length == 0) {
    toastr.error('Please select sadhak profiles.');
    return false;
  }

  $.each(selectedProfileIds, function(i, id){
    form.append('<input type="hidden" name="sadhak_profile[sadhak_profile_ids][]" value="' + id + '" /> ' );
  });

  var eventId = $(window.event.target).attr('data-event-id');

  form.append('<input type="hidden" name="sadhak_profile[event_id]" value="' + eventId + '" /> ' );

  if (action == 'reject') {
      var reasons = [];
      $.each($('.photo_approval_sadhak_profile_reason_of_rejection:checked'), function(i, selectedReason){
        reasons.push(selectedReason.value);
      });
      reasons = reasons.join(',');
      form.append('<input value="' + reasons + '" type="hidden" name="sadhak_profile[status_notes]">');
  }

  form.submit();
  form.html('');
}

//Create & submit approve reject form
function createAndSubmitApproveRejectForm(type){
  var form = $('#photo_approval_approve_reject_form');
  var syid = $(window.event.target).attr('data-id');
  var eventId = $(window.event.target).attr('data-event-id');
  form.attr('method', "put");
  form.attr('action', "/v1/sadhak_profiles/" + syid + '/profile_photo/' + type);
  form.append('<input value="' + eventId + '" type="hidden" name="sadhak_profile[event_id]">');

  if (type === 'reject') {
    var reasons = [];
    $.each($('.photo_approval_sadhak_profile_reason_of_rejection:checked'), function(i, selectedReason){
      reasons.push(selectedReason.value);
    });
    reasons = reasons.join(',');
    form.append('<input value="' + reasons + '" type="hidden" name="sadhak_profile[status_notes]">');
  }
  form.submit();
  form.html('');
}


// Set data upon opening of rejection modal
$(document).on('show.bs.modal', '#photo_approval_sadhak_profile_rejection_reasons_modal', function(){

  var src = $(window.event.srcElement), modalButton = $('#photo_approval_sadhak_profile_rejection_reasons_modal').find('div.modal-footer').find('button:last');

  if (src.hasClass('photo_approval_admin_panel_sadhak_profile_reject')) {
    modalButton.on('click', function(){
      createAndSubmitApproveRejectForm('reject')
    });
    modalButton.attr('data-id', src.attr('data-id'));
    modalButton.attr('data-event-id', src.attr('data-event-id'));
  } else {
    modalButton.on('click', function(){
      approveRejectSelectedProfiles('reject')
    });
    modalButton.attr('data-event-id', src.attr('data-event-id'));
  }

});

// Reset rejection modal
$(document).on('hidden.bs.modal', '#photo_approval_sadhak_profile_rejection_reasons_modal', function(){

  var modalButton = $('#photo_approval_sadhak_profile_rejection_reasons_modal').find('div.modal-body').find('button:last');
  modalButton.off('click');
  modalButton.attr('data-id', '');
  modalButton.attr('data-event-id', '');

  $('.photo_approval_sadhak_profile_reason_of_rejection').prop('checked', false);

});
