    // Attach webcam to DOM element 
    function attachCamera(width, height) {
        Webcam.reset();
        if ($(".camera-snapshot").length) {
            Webcam.set({
                width: width,
                height: height,
                image_format: 'jpeg',
                jpeg_quality: 100,
                fps: 24
            });
            Webcam.set('constraints', {
                optional: [
                    { minWidth: 600 }
                ]
            });
            Webcam.set("swfURL", WEBCAM_SWF);
            Webcam.attach('.camera-snapshot');
        }
    }
    //

    // Take Snap shot by cam and show captured image 
    function take_snapshot() {
        Webcam.snap(function(data_uri) {
            if ($('#cam_captured_snapshot').length) {
                $('#cam_captured_snapshot').val(data_uri);
            }
            $('.selected-snapshot').html($('<img>').attr('src', data_uri));
            $("#cropped_image").html("");
            $('#snapshotSubmit').attr('disabled', true);
        });
    }
    //

    $(document).on("turbolinks:load", function(){
        cameraLoader = $('.loader');
        cameraError = $('.camera-error');
    });


    // Set Captured image to element
    function setImage() {
        if ($('.profilelist-snapshot input[type=radio]:checked').length == 0) {
            toastr.error("Please Select Any One Image.");
            return false;
        }
        var base64Image = $('.profilelist-snapshot input[type=radio]:checked').parent().find('img').attr('src');
        $('#sadhak_profile_advance_profile_attributes_advance_profile_photograph_attributes_name')
            .addClass('ignore')
            .val(null);
        $('#sadhak_profile_advance_profile_attributes_advance_profile_photograph_attributes_image_data_base64').val(base64Image);

        var randomNumber = Math.floor(Math.random() * 10000000);
        $('#photoIdProof')
            .find('.Custinput span').text(randomNumber + '.jpeg')
            .end()
            .find('.uploadedimage').remove()
            .end()
            .append($('<div>').attr('class', 'uploadedimage').append(($('<a>').attr('href', 'javascript:void(0);')
                .append($('<img>').attr('src', base64Image)))))

        Webcam.reset();
        $("#cropped_image").html("");
        $("#profile-selected, #camera-snap").collapse("toggle");
        $("#cameraModal").modal('hide');
    }
    //

    // Attach / Dettach webcam when modal open and close. 
    $(document).on('hide.bs.modal', '#cameraModal', function() {
        Webcam.reset();
        $('#cropped_image').html("");
        $("#profile-selected").removeClass('in');
        $("#camera-snap").addClass("in");
        $('.camera-snapshot').html(cameraLoader.removeClass('hidden'));
    });

    $(document).on('shown.bs.modal', '#cameraModal', function() {
        attachCamera($('.camera-snapshot').width(), $('.camera-snapshot').height());
    });
    //

    // If any Error occurs
    Webcam.on('error', function(err) {
        // an error occurred (see 'err')
        var error = "";
        if (err.name == "PermissionDeniedError"){
            error = "You need to provide access to the camera."
        } else if(err.name == "NotFoundError"){
            error = "No device found."
        }
        else {
            error = "Something went wrong please try again."
        }
        toastr.error(error);
         $('.camera-snapshot').html(cameraError.removeClass("hidden"));
         $('form#capture_img_to_verify button.snapshort').attr('disabled', true);
    });
    //

    Webcam.on( 'live', function() {
        // camera is live, showing preview image
        // (and user has allowed access)
        $('form#capture_img_to_verify button.snapshort').attr('disabled', false);
    } );