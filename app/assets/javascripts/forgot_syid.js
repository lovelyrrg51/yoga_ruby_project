$(document).on('turbolinks:load', function() {
    $('div.forgot_syid input[type="radio"]').on('change', function() {
        $('.tabs').hide();
        $($(this).data("target")).show();
    });

    $('form#search_syid_by_mobile_or_email #medium').on('change', function() {
        var selected_op = $(this).val();
        $('.search_option')
            .find('input').val('').end().addClass("hidden");
        $("#" + selected_op).removeClass("hidden");
    });

    $('form#search_syid_by_details').validate({
        rules: {
            'first_name': "required",
            'date_of_birth': "required"
        },
        submitHandler: function(form) {
            form.submit();
        }
    });

    $('form#search_syid_by_mobile_or_email').validate({
        rules: {
            'medium': "required",
            'email': { required: '#email:visible', email: true },
            'mobile': { required: '#mobile:visible'}
        },
        submitHandler: function(form) {
            form.submit();
        }
    });
})
