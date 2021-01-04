// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.



// If sadhak profile's profession is 'student ,homemaker unemlpoyed'
function checkProfession(ele){

    $("#collapseTwo  .prelative ").find('input').val('');
    if (NON_PROFESSIONAL_PROFESSIONS_CONST.indexOf($(ele).find('option:selected').text()) > -1) {
        $("#collapseTwo")
        .find(".overlapping").addClass("overlay-active");
        $("#collapseTwo")
        .find('.prelative input').valid();
    }else{
        $("#collapseTwo")
        .find(".overlapping").removeClass("overlay-active");
        $("#collapseTwo")
        .find('.prelative input').valid();
    }
}

// After select file input field remove camera snapshot 
function removeCameraSnapshot(ele){
    if (ele.files.length > 0)
    $('#sadhak_profile_advance_profile_attributes_advance_profile_photograph_attributes_image_data_base64').val("")
}

$(document).on("turbolinks:load", function() {
    // body...

    /* sadhak_profile_basic_info */
    $('form#edit_sadhak_profile_basic_info').validate({
        onkeyup: false,
        rules: {
            "sadhak_profile[mobile]": {
                required: function() { return $('#sadhak_profile_email').val() == ""; },
                exactlength: {
                    param: 10,
                    depends: function() {
                        return $('select[name="sadhak_profile[address_attributes][country_id]"]').val() == "113"
                    }
                }     
            },
            "sadhak_profile[email]": { required: function() { return $('#sadhak_profile_mobile').val() == ""; }, email: true },
            "sadhak_profile[first_name]": {
								minlength: 2,
								letterAndSpaceOnly: true,
								required: true 
            },
            "sadhak_profile[last_name]": {
								letterAndSpaceOnly: function(ele){
									return $(ele).val() !== ""
								},
								noSpecialChar: function(ele){
									return $(ele).val() !== ""
								}
            }
        },
        messages: {
	        	"sadhak_profile[first_name]": {
									noSpace: "This field can contain only letters.",
									noSpecialChar: "This field can contain only letters.",
	           },
           	"sadhak_profile[last_name]": {
								letterAndSpaceOnly: "This field can contain only letters.",
								noSpecialChar: "This field can contain only letters.",
						}
        },
        submitHandler: function(form) {
            form.submit();
        }
    });
    $('form#new_sadhak_profile_basic_info').validate({
        onkeyup: false,
        rules: {
            "sadhak_profile[mobile]": { 
                required: function() { return $('#sadhak_profile_email').val() == ""; },
                exactlength: {
                    param: 10,
                    depends: function() {
                        return $('select[name="sadhak_profile[address_attributes][country_id]"]').val() == "113"
                    }
                }
            },
            "sadhak_profile[email]": { required: function() { return $('#sadhak_profile_mobile').val() == ""; }, email: true },
            "sadhak_profile[username]": {
                noSpace: true,
                required: true,
                noSpecialChar: true,
                minlength: 2,
                "remote": '/v1/sadhak_profiles/validate/validate_user_name'
            },
						"sadhak_profile[first_name]": {
								minlength: 2,
								letterAndSpaceOnly: true,
								required: true 
            },
            "sadhak_profile[last_name]": {
								letterAndSpaceOnly: function(ele){
									return $(ele).val() !== ""
								},
								noSpecialChar: function(ele){
									return $(ele).val() !== ""
								}
            },
            "sadhak_profile[address_attributes][other_state]": { 
                    required: function(){ return $('select[name="sadhak_profile[address_attributes][state_id]"]').val() == OTHER_STATE_ID
                }       
            },
            "sadhak_profile[address_attributes][other_city]": { 
                   required: function(){ return $('select[name="sadhak_profile[address_attributes][city_id]"]').val() == OTHER_CITY_ID
                  }    
            }
        },
				messages: {
						"sadhak_profile[username]": {
								noSpace: "This field can contain only  letter and number.",
								noSpecialChar: "This field can contain only letter and number.",
						},
						"sadhak_profile[first_name]": {
								noSpace: "This field can contain only letters.",
								noSpecialChar: "This field can contain only letters.",
						},						
						"sadhak_profile[last_name]": {
								letterAndSpaceOnly: "This field can contain only letters.",
								noSpecialChar: "This field can contain only letters.",
                        }
				},
        submitHandler: function(form) {
            form.submit();
        }
    });

    /* end sadhak_profile_basic_info */



    /* profiles_advance_profile */
    advance_profile_validation_obj = {
        errorPlacement: function(error, element) { 
            if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_photograph_attributes][name]")
                error.appendTo(".photoIdProof");
            else if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_identity_proof_attributes][name]")
                error.appendTo(".identityProof");
            else if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_address_proof_attributes][name]")
                error.appendTo(".addressProof");
            else
                error.insertAfter(element);
    }};

    $('form#edit_sadhak_profiles_advance_profile').validate(advance_profile_validation_obj);
    /* end profiles_advance_profile */


    /* Doctors profile form validations*/ 
    $('form#sadhak_profile_doctors_profile_form').validate();
    /* profile_professiona_details */

    $('form#edit_sadhak_profile_professional_details').validate({
        rules: {
            "sadhak_profile[professional_detail_attributes][designation]": {
                
            },      
            "sadhak_profile[professional_detail_attributes][occupation]": {
                
            },      
            "sadhak_profile[professional_detail_attributes][name_of_organization]": {
                
            },      
            "sadhak_profile[professional_detail_attributes][professional_specialization]": {
                
            },      
            "sadhak_profile[professional_detail_attributes][personal_interests]": {
                
            },      
            "sadhak_profile[professional_detail_attributes][years_of_experience]": {
                digits: true,
            }

        },
        messages:{

        },
        submitHandler: function(form){
            form.submit();
        }
    });

    /* end profile_professiona_details */

    /* sadhak_profiles_spiritual_practice */

    $("form#edit_sadhak_profiles_spiritual_practice").validate();

    /* end sadhak_profiles_spiritual_practice */

    /*  other spiritual association */

    $('#sadhak_profile_other_spiritual_association_form').validate();

    if ($('#yes_radio_other_spiritual_association_').prop('checked')) {
        $('#other_spiritual_associations_toggle_div').removeClass("overlay-active");
    }

    $('#yes_radio_other_spiritual_association_').click(function() {

        $('#other_spiritual_associations_toggle_div').removeClass("overlay-active");

    });

    $('#no_radio_other_spiritual_association_').click(function() {

        $('#other_spiritual_associations_toggle_div').addClass("overlay-active");

    });

    /* end other spiritual association*/

    /* sadhak seva preference*/

    $('#sadhak_profile_sadhak_seva_preference_form').validate();

    $('#sadhak_profile_sadhak_seva_preference_form').submit(function() {

        if ($('#no_radio_voluntary_organisation_').prop('checked')) {
            $('#voluntary_organisation_text_area').val("");
        }

        if ($('#no_radio_expertise_').prop('checked')) {
            $('#expertise_text_area').val("");
        }

    });

    if ($('#yes_radio_voluntary_organisation_').prop('checked')) {
        $('#voluntary_organisation_toggle_div').removeClass("overlay-active");
    }


    $('#yes_radio_voluntary_organisation_').click(function() {

        $('#voluntary_organisation_toggle_div').removeClass("overlay-active");

    });

    $('#no_radio_voluntary_organisation_').click(function() {

        $('#voluntary_organisation_toggle_div').addClass("overlay-active");

    });

    if ($('#yes_radio_expertise_').prop('checked')) {
        $('#expertise_toggle_div').removeClass("overlay-active");
    }


    $('#yes_radio_expertise_').click(function() {

        $('#expertise_toggle_div').removeClass("overlay-active");

    });

    $('#no_radio_expertise_').click(function() {

        $('#expertise_toggle_div').addClass("overlay-active");

    });


    /* end seva association */

    /* medical practitioner*/

    $('#sadhak_profile_medical_practitioners_profile_form').validate();

    /* end medical practitioner*/

    /* guru name*/

    $("#sadhak_profile_name_of_guru_form").validate({
    	rules: {
    		'sadhak_profile[name_of_guru]': {
    			noSpecialChar: true
    		}
    	},
    	submitHandler: function(form){
    		form.submit();
    	}
    });

    /* end guru name*/

    /* SadhakProfileAttendedShivir */

    $('#sadhak_profile_attended_shivir_form').validate();

    /* end SadhakProfileAttendedShivir */

    /* spiritual_journey */

    $('#sadhak_profile_spiritual_journey_form').validate();

    /* end spiritual_journey */

    /* spiritual_journey*/

    $('#sadhak_profile_spiritual_journey_form').validate();

    /*end spiritual_journey*/

    /* aspect of life */

    $(".aspect_feedback_click_rating").rating();

    $('div.rating-stars').click(function() {

        var ele = $(this).find('input.before_after_aspect_feedback').get(0)
        var id = $(ele).attr("data-id");
        var to_do = $(ele).attr("data-to-do");
        var star_input_id = id + '_' + to_do;
        var star_input_value = $("#" + star_input_id)[0].value * 5;

        $('#hidden_' + id + '_' + to_do).val(star_input_value);

    });

    $('#sadhak_profile_aspect_feedback_form').validate();

    $(".caption").hide();
    $(".clear-rating-active").hide();

    /* end aspect of life */

    // Validation on verificationi form
    $("#sadhak_profile_basic_info_verification").validate();

    // Send ajax request for resend verification token
    $(document).on("click", "#sadhak_profile_resend_verification_code", function() {
        $.ajax({
            dataType: "script",
            url: "/v1/sadhak_profiles/" + "<%= @sadhak_profile.id %>" + "/resend_sadhak_profile_verification_token"
        });
    });

});


// Open panel by accordion_id
$(document).on("turbolinks:load", function() {

    var accordion_id = $("#sadhak_profile_accordion_id").val();
    var tagrgetEl = $("#" + accordion_id);
    tagrgetEl.addClass("in");
    $(".Custompanel-group").find("a[data-toggle = collapse]").attr("aria-expanded", false);
    var targetElSibling = tagrgetEl.siblings("div.panel-heading");
    $(".Custompanel-group").find(".glyphicon-minus").toggleClass("glyphicon-minus glyphicon-plus");
    targetElSibling.find(".glyphicon").toggleClass("glyphicon-minus glyphicon-plus");
    targetElSibling.find("a").attr("aria-expanded", true);
    scrollToElement(tagrgetEl);

});

// Show list of more sadhak profiles 
$(document).ready(function() {
    // when the load more link is clicked
    $('.sadhak_profile_load_more_link').click(function(e) {

        // prevent the default click action
        e.preventDefault();

        // hide load more link
        $('.sadhak_profile_load_more_link').hide();

        // get the last id and save it in a variable 'last-id'
        var last_id = $('.sadhak_profile_record_row').last().attr('data-id');

        // make an ajax call passing along our last user id
        $.ajax({
            data: {
                "last_sadhak_profile_id": last_id
            },
            dataType: 'script',
            url: '/sadhak_profiles/load_more_sadhak_profiles',
            success: function(data) {}
        });

    });
});


$(document).on('turbolinks:load', function(){
	$('#sp_accordion_id .panel-collapse').on('shown.bs.collapse', function(){
		var panel_id = $(this).attr('id');
		var base_url = window.location.href;
		var new_url = base_url.substring(0, base_url.lastIndexOf('edit')) + "edit?sp_accordion_id=" + panel_id;
		history.replaceState("", "", new_url);
	});
});