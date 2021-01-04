// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on("turbolinks:load", function() {

    $('#sadhak_profile_sadhak_seva_preference_form').submit(function() {

        if ($('#no_radio_voluntary_organisation_').prop('checked')) {
            $('#voluntary_organisation_text_area').val("");
        }

        if ($('#no_radio_expertise_').prop('checked')) {
            $('#expertise_text_area').val("");
        }

    });

    $('.yes_no_radio_voluntary_organisation_').click(function(){
      $('#voluntary_organisation_toggle_div').toggleClass('overlay-active');
    });
    
    $('.yes_no_radio_expertise_').click(function(){
      $('#expertise_toggle_div').toggleClass('overlay-active');
    });

   /* aspect of life */

    $(".aspect_feedback_click_rating").rating();

    $('div.rating-stars').click(function(){

        var ele = $(this).find('input.before_after_aspect_feedback').get(0)
        var id = $(ele).attr("data-id");
        var to_do = $(ele).attr("data-to-do");
        var star_input_id = id + '_' + to_do;
        var star_input_value = $("#" + star_input_id)[0].value * 5;

        $('#hidden_' + id + '_' + to_do).val(star_input_value);

    });

    $(".caption").hide();
    $(".clear-rating-active").hide();

    /* end aspect of life */ 


    $('#sadhak_profile_step_other_spiritual_association_form').validate();    

    $("#sadhak_profile_step_sadhak_profile_attended_shivir_form").validate();

    $('#sadhak_profile_steps_self_reported_save_cont_form').submit(function(){
        if(!$('#sadhak_profile_steps_sadhak_profile_attended_shivir_fields_tbody').find('tr').length){
            toastr.error('Please Create Self Reported first.');
            return false;
        }
    });

    $('#finish_wizard_ok_button').click(function(){
        window.close();
    });

    $('form#edit_sadhak_profiles_steps_advance_profile').validate({
        errorPlacement: function(error, element) { 
            if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_photograph_attributes][name]")
                error.appendTo(".photoIdProof");
            else if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_identity_proof_attributes][name]")
                error.appendTo(".identityProof");
            else if (element.attr("name") == "sadhak_profile[advance_profile_attributes][advance_profile_address_proof_attributes][name]")
                error.appendTo(".addressProof");
            else
                error.insertAfter(element);
    }});

    $('#sadhak_profile_steps_spiritual_journey_form').validate();
    $('#sadhak_profiles_steps_spiritual_practice_form').validate();
    $('#sadhak_profile_step_sadhak_seva_preference_form').validate();
    $('form#sadhak_profile_step_professiona_details').validate({
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
                
            }
        },
        messages:{

        },
        submitHandler: function(form){
            form.submit();
        }
    });
    $('#sadhak_profile_steps_name_of_guru_form').validate({
    	rules: {
    		'sadhak_profile[name_of_guru]': {
    			noSpecialChar: true
    		}
    	},
    	submitHandler: function(form){
    		form.submit();
    	}
    });
    $('#sadhak_profile_step_medical_practitioners_profile_form').validate();
    $('#sadhak_profile_step_basic_info').validate({
    	rules: {
            "sadhak_profile[first_name]": {
    						noSpace: true,
    						noSpecialChar: true,
    						letteronly: true,
    						noSpecialChar: true
            },
            "sadhak_profile[mobile]": { 
                required: function() { return  $('#sadhak_profile_email').val() == ""; },
                exactlength: {
                    param: 10,
                    depends: function() {
                        return $('select[name="sadhak_profile[address_attributes][country_id]"]').val() == "113"
                    }
                } 
            },
            "sadhak_profile[email]": { required: function() { return $('#sadhak_profile_mobile').val() == ""; }, email: true }
    	},
			messages:{
					"sadhak_profile[first_name]": {
							noSpace: "This field can contain only letters.",
							noSpecialChar: "This field can contain only letters.",
					}
			},
    	submitHandler: function(form){
    		form.submit();
    	}
    });
    $('#edit_sadhak_profiles_steps_doctors_profile').validate();

    $('#sadhak_profile_steps_other_spiritual_associations_save_cont_form').submit(function(){
        $('#sadhak_profile_step_other_spiritual_association_create_button').attr('disabled', 'disabled');
    });

    $('#sadhak_profile_steps_self_reported_save_cont_form').submit(function(){
        $('#sadhak_profile_step_sadhak_profile_attended_shivir_create_button').attr('disabled', 'disabled');
    });

    $('form#sadhak_profile_special_event_sadhak_profile_other_info_form').validate({
        onkeyup: false,
        rules: {
            "sadhak_profile[special_event_sadhak_profile_other_infos_attributes][0][participation_details]": { required: function() { return $("#sadhak_profile_special_event_sadhak_profile_other_infos_attributes_0_would_you_like_to_participate_in_the_devine_mission_of_shivyog_true").is(':checked') } },
            "sadhak_profile[special_event_sadhak_profile_other_infos_attributes][0][case_details]": { required: function() { return $("#sadhak_profile_special_event_sadhak_profile_other_infos_attributes_0_are_you_involved_in_any_litigation_cases_true").is(':checked') } },
            "sadhak_profile[special_event_sadhak_profile_other_infos_attributes][0][ailment_details]": { required: function() { return $("#sadhak_profile_special_event_sadhak_profile_other_infos_attributes_0_are_you_suffering_from_physical_or_mental_ailments_true").is(':checked') } },
            "sadhak_profile[special_event_sadhak_profile_other_infos_attributes][0][medication_details]": { required: function() { return $("#sadhak_profile_special_event_sadhak_profile_other_infos_attributes_0_are_you_taking_medication_true").is(':checked') } },
            "sadhak_profile[special_event_sadhak_profile_other_infos_attributes][0][political_party_name]": { required: function() { return $("#sadhak_profile_special_event_sadhak_profile_other_infos_attributes_0_are_you_member_of_political_party_true").is(':checked') } }
        },
        messages: {
        },
        submitHandler: function(form) {
            form.submit();
        }
    });

 });

$(document).on('click', '.other_info_radio_button', function(){
    $(this).closest('div.col-sm-6').find('div.other_info_overlay_div').toggleClass('overlay-active');
    if($(this).val() == "false"){
        $(this).closest('div.col-sm-6').find('input.other_info_overlay_tag').val("");
    }
});

function checkStepProfession(ele){
    $("#completeProfileProfessionalTab").find('input.overlayToggleInput').val('');

    if (NON_PROFESSIONAL_PROFESSIONS_CONST.indexOf($(ele).find('option:selected').text()) > -1) {
        $("#completeProfileProfessionalTab")
        .find(".overlayToggleDiv").addClass("overlay-active");
        $("#completeProfileProfessionalTab")
        .find('input.overlayToggleInput').valid();
    } else{
        $("#completeProfileProfessionalTab")
        .find(".overlayToggleDiv").removeClass("overlay-active");
        $("#completeProfileProfessionalTab")
        .find('input.overlayToggleInput').valid();
    }

}

$(document).on('click', '.yes_no_radio_other_spiritual_association_', function(){
    if($('#yes_radio_other_spiritual_association_').is(':checked')){
        ($("#sadhak_profile_steps_other_spiritual_associations_fields_tbody").find('tr').length) ? $('#sadhak_profile_steps_other_spiritual_associations_save_cont_button').prop('disabled', false) : $('#sadhak_profile_steps_other_spiritual_associations_save_cont_button').prop('disabled', true);
        $('#sadhak_profile_step_other_spiritual_associations_toggle_div').removeClass('overlay-active');
        
    }else{
        $('#sadhak_profile_step_other_spiritual_associations_toggle_div').addClass('overlay-active');
        $('#sadhak_profile_steps_other_spiritual_associations_save_cont_button').prop('disabled', false);
    }
});