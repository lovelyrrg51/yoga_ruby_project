$(document).on('click', '#select-all', function() {
    $('tbody input[type=checkbox]').prop('checked', $(this).prop('checked'));
});

$(document).on('click', 'tbody.data_list_container input[type=checkbox]', function() {
    $('#select-all').prop('checked', $('tbody.data_list_container input[type=checkbox]:checked').length == $('tbody.data_list_container input[type=checkbox]').length)
});

$(document).on('turbolinks:load', function() {
    $('form#send_report_to_email_list').validate({
	  	rules: {
	  		'recipients': { required: true, email: true }
	  	},
      errorPlacement: function(error, element) {
        if (element.attr("name") == "recipients"){
          error.appendTo("form#send_report_to_email_list .merge-error");
        }
      	else{
    			error.insertAfter(element);
    		}
      },
      submitHandler: function(form){
	  		form.submit();
	  	}
    });
});