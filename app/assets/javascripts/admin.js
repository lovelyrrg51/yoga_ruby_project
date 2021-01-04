$(document).on('turbolinks:load', function(){
  
  $("form.shivir-episode-access-form").validate();
  $("form.farmer-episode-access-form").validate();
  $(".farmer-episode-access").on('cocoon:after-insert', function(event, item){
    $(this).data('insert-timeout', 1000);
    var random_number = parseInt(Math.random() * 10000000000000000);
    item.find("div[id$='_start']").attr('id', random_number + '_start').attr('data-sydatepickerid', random_number);
    item.find("div[id$='_end']").attr('id', random_number + '_end').attr('data-sydatepickerid', random_number);
  });
	$("#sy_event_company_form").validate({
		rules: {
	  "sy_event_company[address_attributes][other_state]": {
	      required: function() {
	       return $('select[name="sy_event_company[address_attributes][state_id]"]').val() == OTHER_STATE_ID
	         }      
     },
	   "sy_event_company[address_attributes][other_city]": {
	   		required: function(){ 
	 				return $('select[name="sy_event_company[address_attributes][city_id]"]').val() == OTHER_CITY_ID
	 				}    
 			}
		},
		messages: {
      
    },
    submitHandler: function(form) {
      form.submit();
    }
	});
});

function authorizationRrowDataOptionsChange(e){
  var id = e.closest('tr').id, button_ele = $('#' + id + '_save_button');
   button_ele.removeAttr("disabled");
  }

function saveAuthorizationRowDataChanges(e){

  var id = e.closest('tr').id;

  var user_id = $('#' + id + '_authorization_row_data_select').val();

  $.ajax({
      data: {
          "user_id": user_id,
          "auth_id": id
      },
      dataType: 'script',
      url: '/v1/admin/update_authorization',
      success: function() {
        $(".simple-single").select2({
            minimumResultsForSearch: Infinity
        });
      }
  });

}

selectEditor = function(e){
  // Email
  if ($(e).val() == 0) {
    $(e).parents('form').find('#cke_email_content').show();
    $(e).parents('form').find('#sms_box').hide();
  }
  // Mob Sms
  else if ($(e).val() == 1) {
    $(e).parents('form').find('#cke_email_content').hide();
    $(e).parents('form').find('#sms_box').show();
  }
  // None
  else {
    return false;
  }
}

