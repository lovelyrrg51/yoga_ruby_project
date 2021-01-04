$(document).on("turbolinks:load", function() {
    $("form#new_user").validate({
        debug: false,
        rules: {
            "user[username]": "required",
            "user[password]": "required"
        },
        messages: {
            "user[username]": "Please input SYID.",
            "user[password]": "Please input password.",
        },
        submitHandler: function(form) {
            form.submit();
        }
    });
});