// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.    
$(document).on("turbolinks:load", function() {
    $('#user_search_by_options').on('change', function() {
        var selected_op = $(this).val();
        $('.search_option').addClass("hidden")
            .find('input').val('');
        $("#" + selected_op).removeClass("hidden");
    });

    $("form#user_reset_password").find("input[type=checkbox]").click(function(){
        var form = $("form#user_reset_password")
        if (form.find("input[type=checkbox]:checked").length > 0) {
            form.find("input[type=checkbox]").prop("checked", false);
            $(this).prop("checked", true);
            form.find("[type=submit]").removeAttr("disabled");
        } else {
            form.find("[type=submit]").attr("disabled", "disabled");
        }

    });
    $("form#update_user_password").validate({
        rules:{
            "user[current_password]" : {
                required: true,
                minlength: 8
            },
           "user[password]": {
                required: true,
                minlength: 8
            },
            "user[password_confirmation]": {
                required: true,
                minlength: 8,
                equalTo: "#user_password"
            } 
        },
        messages: {
            "user[current_password]": {
                required: "Current password cannot be blank."
            },
            "user[password]": {
                required: "New password cannot be blank."
            },
            "user[password_confirmation]": {
                required: "Confirmation password cannot be blank.",
                equalTo: "New password and confirmation password do not match."
            }
        },
        submitHandler: function(form) {
            form.submit();
        },
        errorPlacement: function (error, element) {
          $(element).parents('.input-group').append(error);
        }
    });

    $("form#user_reset_password").validate({
        rules: {
            "user[syid]": {
                required: true
            },
            "user[first_name]": {
                required: "#user_first_name:visible"
            },
            "user[mobile]": {
                required: "#user_mobile:visible"
            },
            "user[date_of_birth]": {
                required: "#user_date_of_birth:visible"
            }
        },
        messages: {
            "user[syid]": {
                required: "SYD cannot be blank."
            },
            "user[first_name]": {
                required: "First name cannot be blank."
            },
            "user[mobile]": {
                required: "Mobile Number cannot be blank."
            },
            "user[date_of_birth]": {
                required: "Date of birth cannot be blank."
            }
        },
        submitHandler: function(form) {
            form.submit();
        },
        errorPlacement: function (error, element) {
          $(element).parents('.input-group').append(error);
        }
    });

    $("form#user_verify_verification_code_and_reset_password").validate({
        rules: {
            "user[verification_code]": {
                required: true
            },
            "user[new_password]": {
                required: true,
                minlength: 8
            },
            "user[confirm_new_password]": {
                required: true,
                minlength: 8,
                equalTo: "#user_new_password"
            }
        },
        messages: {
            "user[verification_code]": {
                required: "Verification Code cannot be blank."
            },
            "user[new_password]": {
                required: "New Password cannot be blank."
            },
            "user[confirm_new_password]": {
                required: "Confirmation Password cannot be blank.",
                equalTo: "New password and confirmation password do not match."
            }
        },
        submitHandler: function(form) {
            form.submit();
        },
        errorPlacement: function (error, element) {
          $(element).parents('.input-group').append(error);
        }
    });


    // Login validation
    $("form#new_user").validate({
        debug: false,
        rules: {
            "user[username]": "required",
            "user[password]": "required"
        },
        messages: {
            "user[username]": "Please input SYID.",
            "user[password]": "Please input Password.",
        },
        submitHandler: function(form) {
            form.submit();
        },
        errorPlacement: function (error, element) {
          $(element).parents('.input-group').append(error);
        }
    });

    // Signup validation
    $("form#signup_user").validate({
        debug: false,
        rules: {
          "user[email]": "required",
          "user[password]": "required",
          "user[password_confirmation]": "required"
        },
        messages: {
          "user[email]": "Please input Eamil.",
          "user[password]": "Please input Password.",
          "user[password_confirmation]": "Please input Confirm Password.",
        },
        submitHandler: function(form) {
            form.submit();
        },
        errorPlacement: function (error, element) {
          $(element).parents('.input-group').append(error);
        }
    });

  $("#search_by_dropdown").change(function(){
    var selected_op = $(this).val();
    $('.search_option').addClass("hidden").find('input').val('');
    $("#" + selected_op).removeClass("hidden");
  })
});