function checkNumeric(e)
{  //With FireFox Support
  var KeyID = (window.event) ? event.keyCode : e.which;
  //alert(KeyID);
  if((KeyID >= 48 && KeyID <= 57)  || (KeyID == 43) || (KeyID == 45)|| (KeyID == 8) || (KeyID == 32) || (KeyID == 37) || (KeyID == 39) || (KeyID == 46) || (KeyID == 13) || (KeyID == 0))
  {
    return true;
  }
  return false;
}

/*Vertical ShivYog Introduction Begins Here*/

function checkForDisable() {
  var current = $(".recipe.active");
  if ($(current).is(".recipe:last")) {
    $(".js-right").addClass("disabled");
  } else if ($(current).is(".recipe:first")) {
    $(".js-left").addClass("disabled");
  }
}

/*Vertical ShivYog Introduction Ends Here*/

function startAjax()
{
  $('.inline_loader').css('display','block');
}

function stopAjax()
{
  $('.inline_loader').css('display', 'none');
}
var flatAccordion = function() {
  var args = {duration: 600};
  $('.flat-toggle .toggle-title.active').siblings('.toggle-content').show();

  $('.flat-toggle.enable .toggle-title').on('click', function() {
    $(this).closest('.flat-toggle').find('.toggle-content').slideToggle(args);
    $(this).toggleClass('active');
  }); // toggle

  $('.flat-accordion .toggle-title').on('click', function () {
    if( !$(this).is('.active') ) {
      $(this).closest('.flat-accordion').find('.toggle-title.active').toggleClass('active').next().slideToggle(args);
      $(this).toggleClass('active');
      $(this).next().slideToggle(args);
    } else {
      $(this).toggleClass('active');
      $(this).next().slideToggle(args);
    }
  }); // accordion
};
//Text Fade in Fade out Animation
/*(function($){
    $.fn.extend({
        rotaterator: function(options) {
            var defaults = {
                fadeSpeed: 500,
                pauseSpeed: 100,
        child:null
            };

            var options = $.extend(defaults, options);

            return this.each(function() {
                  var o =options;
                  var obj = $(this);
                  var items = $(obj.children(), obj);
          items.each(function() {$(this).hide();})
          if(!o.child){var next = $(obj).children(':first');
          }else{var next = o.child;
          }
          $(next).fadeIn(o.fadeSpeed, function() {
            $(next).delay(o.pauseSpeed).fadeOut(o.fadeSpeed, function() {
              var next = $(this).next();
              if (next.length == 0){
                  next = $(obj).children(':first');
              }
              $(obj).rotaterator({child : next, fadeSpeed : o.fadeSpeed, pauseSpeed : o.pauseSpeed});
            })
          });
            });
        }
    });
})(jQuery);*/
//Text Fade in Fade out Animation


/*$(window).scroll(function() {
  var scrolledY = $(window).scrollTop();
  $('.upcoming_events_left_section').css('background-position', 'left ' + ((scrolledY)) + 'px');
});*/


$(document).on('turbolinks:load', function () {
  $('.country-selectize').selectize({
    allowEmptyOption: false,
    preload: true,
    load: function(query, callback){
      $(".selectize-input input[placeholder]").attr("style", "width: 100%;");
    },
  });
  $('form#email_subscription').validate({
    rules: {
      'email': { required: true, email: true },
    },
    errorPlacement: function (error, element) {
      error.insertAfter(element.parent());
    }
  });
  /*Vertical ShivYog Introduction Begins Here*/
  $(".js-navigate").on("click", function() {
    $(".js-navigate").removeClass("disabled");
    var current = $(".recipe.active");
    var findNext = $(current).next(".recipe");
    var findPrev = $(current).prev(".recipe");
    var button = $(this);

    $(current).removeClass("active");
    setTimeout(function() {
      if ($(button).hasClass("js-right")) {
        $(findNext).addClass("active");
        checkForDisable();
      } else if ($(button).hasClass("js-left")) {
        $(findPrev).addClass("active");
        checkForDisable();
      }
    }, 300);
  });

  flatAccordion();

  var recipe_count = $('.recipe-content > .recipe').length; //count slides
  for (var i = 1; i < recipe_count; i++){
    shivyog_introduction_slider_autoplay(i);
  }
  function shivyog_introduction_slider_autoplay(i) {
    setTimeout(function(){
      console.log(i);
      if(i == recipe_count - 1)
      {
        $(".js-right").addClass("disabled");
        $(".js-left").removeClass("disabled");
      }
      var current = $(".recipe.active");
      var findNext = $(current).next(".recipe");
      var findPrev = $(current).prev(".recipe");
      var button = $(".js-navigate");
      $(current).removeClass("active");
      setTimeout(function() {
        if ($(button).hasClass("js-right")) {
          $(findNext).addClass("active");
          checkForDisable();
        } else if ($(button).hasClass("js-left")) {
          $(findPrev).addClass("active");
          checkForDisable();
        }
      }, 300);
    },i * 4000);
  }

  /*Select All Checkboxes*/
  $("#checkboxall_head, #checkboxall_foot").click(function () {
    $(".table_checkbox").prop('checked', $(this).prop('checked'));
  });
  /*Select All Checkboxes*/

  /*Display Registration Action Items on checkbox checked*/
  $(".table_checkbox, #checkboxall_head").on("change", function () {
    var checked = $("#reg_actions_form input.table_checkbox:checked").length > 0;
    if(checked)
    {
      $(".action_items").show(500);
    }
    else {
      $(".action_items").hide(500);
      $("#checkboxall_head"). prop("checked", false);
      return false;
    }
  });
  /*Display Registration Action Items on checkbox checked*/

  /*Registration Status Page - Perform Modal Actions on click of radio buttons*/
  $(document).on('click', '.registration_actions',function(){
    var reg_action = $("input[name=registration_actions]").filter(":checked").val();
    $("input[type='hidden'][name='event_order[action]']").val($(this).val());

    event_order = $("input[name='current_event_order']").val();
    if(reg_action == "upgrade_downgrade")
      {
        $("#transfer_event").hide(500);
        $("#registration_action_proceed_btn").removeAttr("data-toggle");
        $("#registration_action_proceed_btn").removeAttr("data-target");
        var action = "/event_orders/" + event_order + "/upgrade_downgrade"
        $(this).closest('form#reg_actions_form').attr('action', action);
      }
      else if (reg_action == "transfer")
      {
        var selectedLineItems = []
        _.filter($('.table_checkbox'), function(line_item){
          if($(line_item).is(':checked')) selectedLineItems.push($(line_item).closest('tr').attr('id'));
        });
        if(selectedLineItems.length){
          $.ajax({
            data: {
              "selected_line_items": selectedLineItems,
            },
            dataType: 'script',
            url: '/event_orders/' + event_order + '/transfered_events',
            success: function() {
              $("#transfer_event").show(500);
              $("#registration_action_proceed_btn").removeAttr("data-toggle");
              $("#registration_action_proceed_btn").removeAttr("data-target");
            }
          });
        }
      }
      else{
        $("#transfer_event").hide(500);
        $("#registration_action_proceed_btn").removeAttr("data-toggle");
        $("#registration_action_proceed_btn").removeAttr("data-target");
        var action = "/event_orders/" + event_order + "/cancel_registrations"
        $(this).closest('form#reg_actions_form').attr('action', action);

        $(document).on('click', '.cancel_confirm_btn',function(e){
          e.preventDefault()
          var refundable_amount = $("#reg_details_form").find('.refundable-amount').text()
          swal({
            title: "Are you sure you want to cancel ?",
            text: "Please check again your refundable amount is: " + refundable_amount,
            type: "warning",
            showCancelButton: true,
            cancelButtonText: "No, Let me check once again.",
            confirmButtonColor: "#DD6B55",
            showLoaderOnConfirm: false,
            confirmButtonText: "Yes, I am sure !",
            closeOnConfirm: true
            }, function () {
              $('form#cancel_reg_form').submit();
              $('.modal').modal('hide'); // closes all active modal pop ups.
              $('.modal-backdrop').remove(); // removes the grey overlay.
              showNotification("alert-success", "Your request has been initiated !", "bottom", "center", "", "");
              return false;
            });
        });
      }
  });
  /*Registration Status Page - Perform Modal Actions on click of radio buttons*/

  $("#shivyog-journey-carousel").owlCarousel({
    loop: true,
        margin: 10,
    autoplay: true,
    autoplayTimeout: 4000,
    autoplaySpeed: 2500,
    autoplayHoverPause: true,
    responsiveClass: true,
    navSpeed: 3000,
    dotsSpeed: 3000,
    nav: false,
    dots: true,
    responsive: {
                  0: {
                    items: 1,
                    margin: 20,
          nav: false
                  },
                  600: {
                    items: 2,
          margin: 20,
          nav: false
                  },
                  1000: {
                    items: 3,
                    margin: 20,
          nav: false
                  }
                }
  });

  $(".owl-prev > span, .owl-next > span").css("display", "none");

  $('.testimonial-carousel').owlCarousel({
    loop: true,
    margin: 10,
    autoplay: true,
    autoplayTimeout: 7000,
    autoplaySpeed: 2500,
    navSpeed: 3000,
    dotsSpeed: 3000,
    autoplayHoverPause: true,
    responsiveClass: true,
    responsive: {
      0: {
        items: 1,
        nav: false,
        margin: 20
      },
      /*600: {
        items: 3,
        nav: false
      },
      1000: {
        items: 5,
        nav: true,
        loop: false,
        margin: 20
      }*/
    }
  });

  $("#pearls-of-wisdom-carousel").owlCarousel({
    loop: true,
    margin: 10,
    autoplay: true,
    autoplayTimeout: 4000,
    autoplaySpeed: 2500,
    autoplayHoverPause: true,
    responsiveClass: true,
    autoHeight: true,
    navSpeed: 3000,
    dotsSpeed: 3000,
    nav: false,
    dots: true,
    responsive: {
      0: {
        items: 1,
        margin: 20,
        nav: false
      },
      600: {
        items: 1,
        margin: 20,
        nav: false
      },
      1000: {
        items: 1,
        margin: 20,
        nav: false
      }
    }
  });
  $(".owl-prev > span, .owl-next > span").css("display", "none");

  $("#pearls-of-wisdom-carousel-mobile").owlCarousel({
    loop: true,
    margin: 10,
    autoplay: true,
    autoplayTimeout: 4000,
    autoplaySpeed: 2500,
    autoplayHoverPause: true,
    responsiveClass: true,
    autoHeight:true,
    navSpeed: 3000,
    dotsSpeed: 3000,
    nav: false,
    dots: true,
    responsive: {
      0: {
        items: 1,
        margin: 20,
        nav: false
      },
      400: {
        items: 1,
        margin: 20,
        nav: false
      },
      600: {
        items: 1,
        margin: 20,
      }
    }
  });
  $(".owl-prev > span, .owl-next > span").css("display", "none");

  $("#awards-recognitions-carousel").owlCarousel({
    loop: true,
    margin: 10,
    autoplay: true,
    autoplayTimeout: 4000,
    autoplaySpeed: 2500,
    autoplayHoverPause: true,
    responsiveClass: true,
    autoHeight:true,
    navSpeed: 3000,
    dotsSpeed: 3000,
    nav: false,
    dots: true,
    responsive: {
      0: {
        items: 1,
        margin: 20,
        nav: false
      },
      600: {
        items: 1,
        margin: 20,
        nav: false
      },
      1000: {
        items: 1,
        margin: 20,
        nav: false
      }
    }
  });
  $(".owl-prev > span, .owl-next > span").css("display", "none");

  /*ShivYog Pillars*/
  var $cont = document.querySelector('.cont');
  var $elsArr = [].slice.call(document.querySelectorAll('.el'));
  var $closeBtnsArr = [].slice.call(document.querySelectorAll('.el__close-btn'));

  setTimeout(function() {
    if ($cont)
      $cont.classList.remove('s--inactive');
  }, 200);

  $elsArr.forEach(function($el) {
    $el.addEventListener('click', function() {
      if (this.classList.contains('s--active')) return;
      $cont.classList.add('s--el-active');
      this.classList.add('s--active');
    });
  });

  $closeBtnsArr.forEach(function($btn) {
    $btn.addEventListener('click', function(e) {
      e.stopPropagation();
      $cont.classList.remove('s--el-active');
      document.querySelector('.el.s--active').classList.remove('s--active');
    });
  });
  /*ShivYog Pillars*/
//Open Video in Modal Popup

// Gets the video src from the data-src on each button

$(' #da-thumbs > li ').each( function() { $(this).hoverdir(); } );

var $videoSrc;
$('#shivyog_video, #shivyog_impact_video_01, #shivyog_impact_video_02, #dr_shivanand_video, #dr_shivanand_talk, .js-video-popup').click(function() {
    $videoSrc = $(this).data( "src" );
});
$('#dr_shivanand_video').click(function() {
    $videoSrc = $(this).data( "src" );
});
$('#shivyog_impact_video_01').click(function() {
    $videoSrc = $(this).data( "src" );
});
if($videoSrc) {
  console.log($videoSrc);
}

// when the modal is opened autoplay it
$('#myModal').on('shown.bs.modal', function (e) {

// set the video src to autoplay and not to show related video. Youtube related video is like a box of chocolates... you never know what you're gonna get
$("#video").attr('src',$videoSrc + "?rel=0&amp;showinfo=0&amp;modestbranding=1&amp;autoplay=1" );
});


// stop playing the youtube video when I close the modal
$('#myModal').on('hide.bs.modal', function (e) {
    // a poor man's stop video
    $("#video").attr('src',$videoSrc);
}) ;

//Open Video in Modal Popup

/* Scroll To A Particular Element */
$('a.scrollto[href^="#"]').on('click', function(event) {
  //alert('clicked');return false;
    //var target = $(this.getAttribute('href'));
  var target = $(".find_event_form");
  //alert(this);return false;
  //$('.find_event_form').find('li.active').removeClass('active');
  //$(this).find('li').addClass('active');
    if( target.length ) {
        event.preventDefault();
        $('html, body').stop().animate({
            scrollTop: target.offset().top - 120
        }, 1500);
    $("#search_event").focus();
    }
});

/* Scroll To A Particular Element */

  /*Tabs to Accordion*/

  /* $('#first').mateTabs();*/
   //$('#second').mateTabs();

  /*Tabs to Accordion*/

/*$(".testimonial-slider").owlCarousel({
        autoPlay: 5000,
        items : 2,
    margin: 40

    });

$(".what-makes-different-slider").owlCarousel({
        autoPlay: 5000,
        items : 1,
    margin: 40

    });  */

//Go to top button
$("#go_to_top").hide();
  // fade in #back-top
  /*$(function () {
    $(window).scroll(function () {
      if ($(this).scrollTop() > 200) {
        $('#go_to_top').fadeIn();
      } else {
        $('#go_to_top').fadeOut();
      }
    });*/

    // scroll body to 0px on click
    /*$('#go_to_top').click(function () {
      $('body,html').animate({
        scrollTop: 0
      }, 3000);
      return false;
    });*/
  //});
//Go to top button

//Contact Form Submit
$("#ajax-contact-form").submit(function() {
      $('#note_contact_form').empty();
      $('#loading').css('display','block');
      //return false;
      var str = $(this).serialize();
      $('#ajax-contact-form').find('input, textarea, button, select').attr('disabled',true);
        $.ajax({
          type: "POST",
          url: "contact_form_submit.php",
          data: str,
          success: function(msg) {
          $('#loading').css('display','none');
          $('#ajax-contact-form').find('input, textarea, button, select').attr('disabled',false);
            // Message Sent - Show the 'Thank You' message and hide the form
            /*if(msg == 'OK') {
              result = '<div class="notification_ok"><p>Your message has been sent. Thank you!</p></div>';
              $("#ajax-contact-form").get(0).reset(); //Include jquery 1.9.1 for this if necessary
              //$('#fields').find('form')[0].reset();
              //$("#fields").hide();
            } else {
              result = '<div class="notification_error"><p>'+msg+'</p></div>';
            }*/
            result = msg;
            $('#note_contact_form').html(result);
          }
        });
        return false;
});
//Contact Form Submit

//$(window).stellar();
    var links = $('.navbar-nav').find('li');
  slide = $('.slide');
    blue_button = $('.blue_button');
  logo = $('.logo');
  go_to_top = $('#go_to_top');
    mywindow = $(window);
    htmlbody = $('html,body');

  /*if (mywindow.scrollTop() < 1) {
    $('.navbar-nav li[data-slide="1"]').addClass('active');
  }

    slide.waypoint(function (event, direction) {

        dataslide = $(this).attr('data-slide');

        if (direction === 'down') {
        $('.navbar-nav li[data-slide="' + dataslide + '"]').addClass('active').prev().removeClass('active');
        }
        else {
            $('.navbar-nav li[data-slide="' + dataslide + '"]').addClass('active').next().removeClass('active');
        }

    });*/

    mywindow.scroll(function () {
        if (mywindow.scrollTop() == 0) {
        $('.navbar-nav li[data-slide="1"]').addClass('active');
            $('.navbar-nav li[data-slide="2"]').removeClass('active');
        }
    // if (mywindow.scrollTop() < 20) {
    //     $('.wsmainfull').addClass('menutop');
    //     $('.wsmenu-list').removeClass('menuscroll');
    // }
    // if(mywindow.scrollTop() > 30)
    // {
    //   $('.wsmainfull').removeClass('menutop');
    //   $('.wsmenu-list').addClass('menuscroll');
    // }
    });

});

/*  Tooltip  */
$( function()
{
  var targets = $( '[rel~=tooltip]' ),
    target  = false,
    tooltip = false,
    title  = false;

  targets.bind( 'mouseenter', function()
  {
    target  = $( this );
    tip    = target.attr( 'title' );
    tooltip  = $( '<div id="tooltip"></div>' );

    if( !tip || tip == '' )
      return false;

    target.removeAttr( 'title' );
    tooltip.css( 'opacity', 0 )
         .html( tip )
         .appendTo( 'body' );

    var init_tooltip = function()
    {
      if( $( window ).width() < tooltip.outerWidth() * 1.5 )
        tooltip.css( 'max-width', $( window ).width() / 2 );
      else
        tooltip.css( 'max-width', 340 );

      var pos_left = target.offset().left + ( target.outerWidth() / 2 ) - ( tooltip.outerWidth() / 2 ),
        pos_top   = target.offset().top - tooltip.outerHeight() - 20;

      if( pos_left < 0 )
      {
        pos_left = target.offset().left + target.outerWidth() / 2 - 20;
        tooltip.addClass( 'left' );
      }
      else
        tooltip.removeClass( 'left' );

      if( pos_left + tooltip.outerWidth() > $( window ).width() )
      {
        pos_left = target.offset().left - tooltip.outerWidth() + target.outerWidth() / 2 + 20;
        tooltip.addClass( 'right' );
      }
      else
        tooltip.removeClass( 'right' );

      if( pos_top < 0 )
      {
        var pos_top   = target.offset().top + target.outerHeight();
        tooltip.addClass( 'top' );
      }
      else
        tooltip.removeClass( 'top' );

      tooltip.css( { left: pos_left, top: pos_top } )
           .animate( { top: '+=10', opacity: 1 }, 500 );
    };

    init_tooltip();
    $( window ).resize( init_tooltip );

    var remove_tooltip = function()
    {
      tooltip.animate( { top: '-=10', opacity: 0 }, 500, function()
      {
        $( this ).remove();
      });

      target.attr( 'title', tip );
    };

    target.bind( 'mouseleave', remove_tooltip );
    tooltip.bind( 'click', remove_tooltip );
  });
});
/*  Tooltip  */
