// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on("turbolinks:load", function(){
	$('form#collection_form').validate();
	$('form#episode_collection_form').validate();

	    $('.episodes-form')
		.on("cocoon:before-remove", function(event, item) {
			$(this).data('remove-timeout', 1000);
    		item.fadeOut('slow');
			if($(".nested-fields:visible").length == 2){
			  	$(".remove_fields")[0].style.display="none";
				// event.preventDefault();
			}else if($(".nested-fields:visible").length == 1){
			  	event.preventDefault();
				toastr.error("Episodes are required. Please add episodes.");
			}
		});
		$('.episodes-form')
		.on("cocoon:after-insert", function(event, item) {
			$(this).data('insert-timeout', 1000);
			var random_number = parseInt(Math.random() * 10000000000000000);
			item.find("div[id$='_start']").attr('id', random_number + '_start').attr('data-sydatepickerid', random_number);
			item.find("div[id$='_end']").attr('id', random_number + '_end').attr('data-sydatepickerid', random_number);
		});

})

$(document).on('click', '.addMoreAnnouncementButton', function () {
	$(".announcementWrapper").append('<div class="box bordered-input mg-b10"><div class="dropdown dropdown-field has-error has-feedback"><input type="text" name="announcement_text[]" class = "form-control noBorder field"><span class="glyphicon glyphicon-remove form-control-feedback removeAnnouncementButton" aria-hidden="true"></span></div></div>')
})

$(document).on("click","removeAnnouncementButton", function(e) {
	$(this).closest('.box bordered-input mg-b10')
})