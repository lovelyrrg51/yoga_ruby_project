// Turbolink:load function
$(document).on("turbolinks:load", function() {

    $(".mCustomScrollbar").mCustomScrollbar();
    $(".tableScrollbar").mCustomScrollbar({
      axis:"x"
    });
    $(".Scrollbarhv").mCustomScrollbar({
      axis:"yx",
			callbacks:{
			    onInit:function(){
			    	if ($(this).find('table').length > 0 ){
							var TotalTableHeight = $(this).find('table').outerHeight() + 12;
							// Set scroller container height acc to table height
							$(this).css('height',TotalTableHeight);
						}
			    }
			}
    });

    var footerheight = $('.footerArea').outerHeight();
    $('.footerArea').css("height", footerheight);
    $('body').css("margin-bottom", footerheight);
    
    if ($(".footerArea").length == 0) {
      $("body, html").addClass("height-full");
    }

      // Right panel //
    var windowheight = $(window).outerHeight();
    var windowwidth = $(window).width();
    var heightCntrl = $('.rightCntrl').outerHeight();
    if(windowwidth < 991) {
      $('.leftCntrl .innerlist').css('max-height', windowheight);
    }else {
      $('.leftCntrl .innerlist').css('max-height', heightCntrl);
    }

    // Desktop search //
    $(".searchbg .form-control").click(function() {
        $('.overlay').addClass('overlay-active');
        $('body').addClass('noscroll');
    });

    $(".overlay").click(function() {
        $(this).removeClass('overlay-active');
        $('.searchbg').removeClass('activesearch');
        $('.leftmenu-list').removeClass('active').trigger("textChanged");
        $('.asideCntrl').removeClass('aside-show');
        $('body').removeClass('noscroll');
    });

    $('.searchbg .dropdown-menu.dropdownCntrl ul').on('click', function(event){
        event.stopPropagation();
    });

    // mobile js  //
    // mobile search from top //
    $('.searchform, .searchforum').click(function() {
        $('.searchbg').addClass('activesearch');
        $('.searchbg .form-control').focus();
        $('.overlay').addClass('overlay-active');
        $('body').addClass('noscroll');
    });

    // Accordorn Panel Group //
    $('.panel-group').on('hidden.bs.collapse', toggleIcon);
    $('.panel-group').on('shown.bs.collapse', toggleIcon);

    // select 2 main //
    $(".basic-single").select2();

    // select 2 without input search //
    $(".simple-single").select2({
        minimumResultsForSearch: Infinity
    });

    // multiple select box //
    $('.multiple-select').select2({
        multiple: true
    });

    // Custom JS Adding to select 2 //
    $('.selectTwo-dropdown .basic-single, .multipleboxfield .multiple-select, .selectTwo-dropdown .simple-single').on('select2:open', function(){
      $('.select2-results').addClass('CustomScrollbar').mCustomScrollbar(); 
    });

    $('.multipleboxfield .select2-selection--multiple').click(function(){
        $(this).mCustomScrollbar();
    });

    $('.tabledrop .select2.select2-container, .Select-dropdown .select2.select2-container').click(function() {
        $('.select2-dropdown.select2-dropdown--below').addClass('dropmargin');
        $('.select2-dropdown.select2-dropdown--above').addClass('dropmargin');
    });

    $('.inputselect-drop .select2.select2-container').click(function() {
        $('.select2-dropdown.select2-dropdown--below').addClass('inputdisabled');
        $('.select2-dropdown.select2-dropdown--above').addClass('inputdisabled');
    });

    // start Rating //
    $("#input-id").rating({
        showClear: false,
        showCaption: false

    });

    // tool tip //
    $('[data-toggle="tooltip"]').tooltip();

      // bootstrap-tags input //
    $('.outbox .bootstrap-tagsinput').hide();
    $('.box-taginput .tagsinput').on('focus', function() {
      $(this).removeClass('box-field');
      $(this).parent().find('.bootstrap-tagsinput').show();
      $(this).siblings('.bootstrap-tagsinput').find('input').focus();
    });

    $('.outbox .bootstrap-tagsinput > input').on('focus', function() {
      $.each($(".outbox .bootstrap-tagsinput"), function(){
        if (!$(this).is($(event.target.parentElement))){
          $(this).hide();
          $(this).parent().find('.tagsinput').addClass('box-field');
        }
      });
    });

    $(document).click(function(e) {
      $.each($(".outbox .bootstrap-tagsinput"), function() {
        if (!$(this).is($(event.target.parentElement))){
          $(this).hide();
          $(this).parent().find('.tagsinput').addClass('box-field');
        }
      });
    });

    // Tool tips //
    $('[data-toggle="tooltip"]').tooltip();

    // Refine PAnel  Menu //
    $('.leftmenu-btn').click(function() {
     if($(window).width()>991) {
       $(this).parents('.leftCntrl').find('.leftmenu-list').toggleClass('active').trigger("textChanged");
       $(this).parents('.leftCntrl').next('.rightCntrl').toggleClass('p-active');
     }
     else {
       $('.leftmenu-list').addClass('active').trigger("textChanged");
       $('.overlay').addClass('overlay-active');
       $('body').addClass('noscroll');
     }

     if($(window).width()<1380 && $(window).width()>991) {
       $(this).parents('body').find('.asideCntrl').addClass('aside-collapsed').end()
       .find('.SectionCntrl').addClass('Section-expand').end()
       .find('.footerArea').addClass('footercollapsed');
       innermenubar();
         }
    });

    // Left Menu //
    $('.leftnav-list li a').click(function() {
      $('.leftnav-list li').removeClass('active');
      $(this).parent('li').addClass('active');
    });

    $('.subCntrl-menu ul li a').click(function() {
        $('.subCntrl-menu ul li').removeClass('subactive');
        $(this).parent('li').addClass('subactive');
        $(this).parents('li').addClass('active');
        $('.subCntrl-menu ul li').removeClass('active');
    });

   // wizerd steps //
    $(".next-step").click(function (e) {
      $('.tab-pane').removeClass('active');
      $(this).parents('.tab-pane').next().addClass('active');
    });

    $(".prev-step").click(function (e) {
      $('.tab-pane').removeClass('active');
      $(this).parents('.tab-pane').prev().addClass('active');
    });
 


    // information block //
    $('.infoicon').click(function() {
        event.stopPropagation();
        $($(this).data('target')).modal('show');
        // $(this).parents('a').removeAttr('data-toggle', 'collapse');
    });

    $('.btnclose, .infomationmodal').click(function(){
        $('.infoicon').parents('a').attr('data-toggle', 'collapse');
    });

    $(".select2basic").select2();

    // Date picker //
    $('.datetoggle').datetimepicker({
        format: 'MMM DD, YYYY',
        ignoreReadonly: true,
        widgetPositioning: {
            vertical: 'bottom'
        },
        icons: {
          up: "fa fa-chevron-up",
          down: "fa fa-chevron-down",
          next: "fa fa-chevron-right",
          previous: "fa fa-chevron-left"
        }
    }).on('dp.show', function(){
        // debugger;
    });

    $('.timetoggle').datetimepicker({
        format: 'LT',
        ignoreReadonly: true,
        widgetPositioning: {
            vertical: 'bottom'
        },
        icons: {
          up: "fa fa-chevron-up",
          down: "fa fa-chevron-down",
          next: "fa fa-chevron-right",
          previous: "fa fa-chevron-left"
        }
    }).on('dp.show', function(){
        // debugger;
        $('.bootstrap-datetimepicker-widget').addClass('time-picker');
  });
  
  // Pop Over //
  $("[data-toggle=popover]").popover({
    html: true,
    content: function() {
        return $('#popover-content').html();
    }
  });

  $('.outbox .select2.select2-container').click(function() {
    $('.select2-dropdown.select2-dropdown--above').addClass('outbox-dropdown');
  });

  /* Tab nav */
  $('.nav-custpilled li a[data-toggle="tab"]').click(function (e) {
    if($('li').hasClass('active')) {
      $('input[type=radio]').removeAttr('Checked');
      $(this).find('input[type=radio]').attr('Checked','checked');
    }
  });

  // Middle contain box
  var headerHeight = $('.headerCntr').outerHeight();
  var footerHeight = $('.footerArea').outerHeight();
  var h_Height = $('.headingtittle-h2').outerHeight();
  

  var TotalHeight = headerHeight + footerHeight + h_Height;
  var middleheight = windowheight - TotalHeight - 120;
  $('.registrationstatusCntrl.boxsection-lg, .boxheightCntrl').css({'height': middleheight});
  if(windowwidth > 1400) {
     $('.boxheight').css({'height': middleheight});
  }

  var searchListHeight = windowheight - 90;
  $('.js-searchListHeight').css({'max-height' : searchListHeight, 'overflow': 'auto'});

});

// Bootstrap tag Input field //
$(document).on('beforeItemAdd', '.box-taginput .tagsinput', function(event) {
  $(this).siblings('.outbox .bootstrap-tagsinput').addClass('bootstrap-tag');
}).on('itemRemoved', '.box-taginput .tagsinput', function(event) {
  if ($(this).val().length) {
    $(this).siblings('.outbox .bootstrap-tagsinput').addClass('bootstrap-tag');
  } else {
    $(this).siblings('.outbox .bootstrap-tagsinput').removeClass('bootstrap-tag');
  }
  window.event.stopPropagation();
});

// toggle icon //
function toggleIcon(e) {
    $(e.target)
        .prev('.panel-heading')
        .find(".more-less")
        .toggleClass('glyphicon-plus glyphicon-minus');
};

equalheight = function(container) {
  
      var currentTallest = 0,
          currentRowStart = 0,
          rowDivs = new Array(),
          $el,
          topPosition = 0;
      $(container).each(function() {
  
          $el = $(this);
          $($el).height('auto')
          topPostion = $el.position().top;
  
          if (currentRowStart != topPostion) {
              for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++) {
                  rowDivs[currentDiv].height(currentTallest);
              }
              rowDivs.length = 0; // empty the array
              currentRowStart = topPostion;
              currentTallest = $el.height();
              rowDivs.push($el);
          } else {
              rowDivs.push($el);
              currentTallest = (currentTallest < $el.height()) ? ($el.height()) : (currentTallest);
          }
          for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++) {
              rowDivs[currentDiv].height(currentTallest);
          }
      });
  }
var windowheight = $(window).outerHeight();
// Search list height equal //
$(document).on('shown.bs.dropdown', '.input-group', function() {
  equalheight('.searchbg ul li .searchlist');
});

// Select2 //
$(document).on('select2:open', '.basic-single, .simple-single', function(e){
    if ($(e.target).parents('.tableCntrl, .tabledrop, .Select-dropdown, .outerSelect').length) {
        $('.select2-dropdown').addClass('innerbox');
    } else if($(e.target).parents('.outbox').length) {
        $('.select2-dropdown').addClass('outerbox');
    }
});

$(document).on('select2:open', '.multiple-select', function(e){
    if ($(e.target).parents('.tableCntrl, .outbox').length) {
        $('.select2-dropdown').addClass('multiplebox');
    }
});

function menubar() {
  if (window.matchMedia('(min-width: 992px)').matches) {
    $('.asideCntrl').toggleClass('aside-collapsed');
    $('.asideCntrl').parents('.wrapperCntrl').find('.SectionCntrl').toggleClass('Section-expand');
    $('.asideCntrl ul li').find('.collapse').removeClass('in');
    $('body').find('.footerArea').toggleClass('footercollapsed');
    innermenubar();
  }
  else {
    $('.leftmenu-list').removeClass('active').trigger("textChanged");
    $('.asideCntrl').toggleClass('aside-show');

    if ($('.leftmenu-list').hasClass("active")) {
     $('.overlay').toggleClass('overlay-active');
    }
    else {
     if($('.asideCntrl').hasClass('aside-show')){
      $('.overlay').addClass('overlay-active');
      $('body').addClass('noscroll');
     } else {
      $('.overlay').removeClass('overlay-active');
      $('body').removeClass('noscroll');
     }
    }
  }
};

// text change //
$(document).on('textChanged', '.leftmenu-list', function() {
  if ($(this).hasClass('active')) {
    $('.leftmenu-btn span').text('HIDE MENU');
    $('.leftmenu-btn i').removeClass('fa fa-angle-double-left');
    $('.leftmenu-btn i').addClass('fa fa-angle-double-right');
  } else {
    $('.leftmenu-btn span').text('OPEN MENU');
    $('.leftmenu-btn i').removeClass('fa fa-angle-double-right');
    $('.leftmenu-btn i').addClass('fa fa-angle-double-left');
  }
});

function innermenubar() {
 if($('.asideCntrl').hasClass('aside-collapsed')) {
   $('div[role="tabpanel"]').collapse('hide');
   $('.asideCntrl ul li.panel > a').removeAttr("data-toggle");
   $('.asideCntrl ul li.panel > a').removeAttr("aria-expanded");
   $('.asideCntrl .aside-inner').removeClass('mCustomScrollbar');
   $('.asideCntrl .aside-inner').find('.mCustomScrollBox, .mCSB_container').css('overflow', 'visible');
 }
 else {
   $('.asideCntrl ul li.panel > a').attr('aria-expanded', 'false');
   $('div[role="tabpanel"] li.active').parents('div[role="tabpanel"]').collapse('show').siblings('a').attr('aria-expanded', 'true');
   $('.asideCntrl ul li.panel > a').attr('data-toggle', 'collapse');
   $('.asideCntrl .aside-inner').addClass('mCustomScrollbar');
   $('.asideCntrl .aside-inner').find('.mCustomScrollBox, .mCSB_container').css('overflow', 'hidden');
 }
}


function modalHeight() {
  var windowheight = $(window).outerHeight();
  var windowwidth = $(window).outerWidth();
  if(windowwidth > 991) {
    var modalHeight = windowheight - 172;
    $('.Custommodal .modal-body').css('max-height', modalHeight);
  }
  else {
    var modalHeight = windowheight - 152;
    $('.Custommodal .modal-body').css('max-height', modalHeight);
  }
}

function setupModal(){
  modalHeight();
  $(".mCustomScrollbar").mCustomScrollbar();
}

$(document).on('shown.bs.modal', function(){
  setupModal();
});