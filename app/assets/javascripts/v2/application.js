//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require owl.carousel
//= require popper
//= require bootstrap4
//= require mdb
//= require selectize
//= require pace/pace

//= require v2/js.cookie
//= require v2/megamenu
//= require v2/common_functions
//= require v2/jquery.fadethis
//= require v2/modernizr.custom

//= require v2/jquery.slimscroll
//= require v2/bootstrap-notify
// require v2/jquery.inputmask.bundle

// require v2/dialogs
//= require v2/notifications
//= require v2/admin
//= require v2/jquery.validate
//= require v2/jquery.datetimepicker.full


//= require v2/jquery.dataTables
//= require dataTables.bootstrap4
// require v2/dataTables.buttons.min
//= require dataTables.conditionalPaging
// require v2/buttons.flash.min
// require v2/jszip.min
// require v2/pdfmake.min
// require v2/vfs_fonts
// require v2/buttons.html5.min
// require v2/buttons.print.min

//= require v2/jquery.hoverdir
//= require v2/jquery-datatable
//= require v2/tooltips-popovers
//= require v2/bootstrap-datepicker
//= require v2/jquery.calendario
//= require v2/data-table
//= require v2/sweetalert.min

//= require v2/handlebars.min
//= require v2/infobubble.min
//= require v2/jquery.storelocator
//= require v2/basic-form-elements
//= require v2/forum
//= require v2/sadhak_profile
//= require social-share-button
//= require unobtrusive_flash
//= require v2/user_confirm_verification_code

$(document).on('turbolinks:load', function () {

  $(window).fadeThis({
    speed: 1500,
    reverse: false,
  });
  $('#teacher_availability_cal_day_03').datetimepicker({
    inline: true,
    allowTimes: ['01:00', '03:00', '06:00', '08:00', '10:00', '11:00', '13:00', '14:30', '17:00'],
    allowDates: ['03.04.2019', '06.04.2019', '08.04.2019', '11.04.2019', '12.04.2019', '13.04.2019', '14.04.2019', '15.04.2019', '17.04.2019', '19.04.2019', '22.04.2019', '24.04.2019', '20.04.2019', '26.04.2019'],
    formatDate: 'd.m.Y',
    onSelectTime: function () {
      console.log('called')
    }
  });

  $('#teacher_availability_cal_day_04').datetimepicker({
    inline: true,
    allowTimes: ['12:00', '13:00', '15:00',
      '17:00', '17:20', '19:00', '20:00'],
    allowDates: ['14.04.2019', '15.04.2019', '16.04.2019', '18.04.2019', '02.04.2019', '05.04.2019', '08.04.2019', '10.04.2019', '20.04.2019'], formatDate: 'd.m.Y',
    onSelectTime: function () {
      console.log('called')
    }
  });

  // blog archives
  $('#blog_post_archives_calendar').datetimepicker({
    inline:true,
    timepicker: false
  });
});

document.addEventListener("turbolinks:before-cache", function () {
  $('script[nonce]').each(function (index, element) {
    $(element).attr('nonce', element.nonce)
  })
})

// unobtrusive flash
flashHandler = function (e, params) {
  var type

  switch (params.type) {
    case 'notice':
      type = 'alert-success'
      break
    case 'error':
      type = 'alert-danger'
      break
    case 'success':
      type = 'alert-success'
      break
    case 'alert':
      type = 'alert-danger'
      break
    default:
      type = 'alert-warning'
  }

  showNotification(type, params.message, 'bottom', 'center', ', ');
};
$(window).bind('rails:flash', flashHandler);
