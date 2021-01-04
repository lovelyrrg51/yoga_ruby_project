$(document).on('turbolinks:load', function() {
  $("#js-sadhak-avatar-fileuploader").change(function(e) {
    var fd = new FormData();
    var file = e.currentTarget.files[0];
    if (!file || typeof file.name === "undefined") {
      showNotification("alert-danger", "Failed to upload avatar", "bottom", "center", "", "");
      $("#js-sadhak-avatar-fileuploader").val('');
      return;
    }

    var filesize = ((file.size/1024)/1024).toFixed(4); // MB
    if (filesize > 5) {
      showNotification("alert-danger", "File size exceeds the limit (5 MB)", "bottom", "center", "", "");
      $("#js-sadhak-avatar-fileuploader").val('');
      return;
    }
    fd.append( 'avatar',  file)

    $.ajax({
      url: '/avatars',
      data: fd,
      processData: false,
      type: 'POST',
      contentType: false,
      cache: false,
      mimeType: 'multipart/form-data',
      dataType: 'JSON',
      beforeSend: function() {
        $('span.js-upload-text').text('Uploading...')
      }
    })
    .done(function (data) {
      $('img#js-sadhak-avatar').attr('src', data.avatar)
      showNotification("alert-success", "Your profile image successfully uploaded", "top", "center", "", "");
    })
    .error(function () {
      showNotification("alert-danger", "Failed to upload avatar", "bottom", "center", "", "");
    })
    .always(function () {
      $('span.js-upload-text').text('Upload New Image')
    })
  })
})
$('.my-profile-tabs li').click(function () {
  if ($(this).find('a').attr('id') != 'tab-change_password_settings' && window.location.search != ""){
    var newUrl = window.location.href.split('?')[0];
    window.history.pushState({}, document.title, newUrl)
  }
});
