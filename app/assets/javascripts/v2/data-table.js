function dataTableDefaultConfig() {
    return {
        processing: true,
        serverSide: true,
        deferRender: true,
        searching: true,
        autoWidth: false,
        filter: true,
        pageLength: 20,
        lengthMenu: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
        language: {
            "lengthMenu": "Displaying _MENU_ records per page",
            "zeroRecords": "NMS, Nothing found.",
            "info": "Showing page _PAGE_ of _PAGES_",
            "infoEmpty": "No records available",
            "infoFiltered": "",
            "info": "Showing _PAGE_ of _PAGES_",
            "sLengthMenu": "_MENU_ per page",
            "paginate": {
              "next": '<i class="fa fa-angle-right" aria-hidden="true"></i>',
              "previous": '<i class="fa fa-angle-left" aria-hidden="true"></i>'
            }
        },
        aoColumnDefs: [{
        'bSortable': false,
        'aTargets': ['nosort']
      }]
    }
}

$(document).on('turbolinks:load', function() {
    $("table.datatable").each(function() {
        var url = $(this).data('url');

        var dataTableDefaultConfiguration = dataTableDefaultConfig();
        if($(this).hasClass('past_event_datatable')){
          dataTableDefaultConfiguration['aaSorting']=[[3, 'desc']]
        }
        if ( $(window).width() < 767 ){
            dataTableDefaultConfiguration["pagingType"] = "simple";
        }
        var config = $(this).data('config');
        if (config === null || config === undefined || typeof config === 'string') {
          config = {
            conditionalPaging: true
          };
        }
        var table = $(this).DataTable($.extend(config, dataTableDefaultConfiguration, {
            ajax: {
                "url": url,
                "data": function(d) {
                  d.country_id = $("select[name='country_id']").val();
                  d.state_id = $("select[name='state_id']").val();
                  d.city_id = $("select[name='city_id']").val();
                  d.graced_by = $("select[name='graced_by']").val();
                  d.event_start_date = $("input[name='event_start_date']").val();
                  d.event_end_date = $("input[name='event_end_date']").val();
                  d.event_id_start_range = $("input[name='event_id_start_range']").val();
                  d.event_id_end_range = $("input[name='event_id_end_range']").val();
                  d.event_type_id = $("select[name='event_type_id']").val();
                  d.event_status = $("select[name='event_status']").val();
                  d.action_page = $("input[name='action_page']").val();
                }
            }
        }));
    });
    $('#data-table-filter').click(function(){
        if($("select[name='country_id']").val() == ""){
            toastr.error('Please a select filter field.');
            return false;
        }
        $('.lobibox-notify-wrapper').remove();
        $("table.datatable").DataTable().ajax.reload();
    });

    $('#event-data-table-filter').click(function(){
        var all_blank = true;
        $(this).parents('.filter-panel').find('input:visible, select:visible').each(function(){
           if($(this).val() != ''){
            all_blank  = false;
           }
        });
        if(all_blank){
            toastr.error('Please select a filter field.');
            return false;
        }
        $('.lobibox-notify-wrapper').remove();
        $("table.datatable").DataTable().ajax.reload();
    });
});


$(document).on('turbolinks:before-cache', function() {
    $("table.datatable").each(function() {
        var table = $(this).DataTable();
        if (table !== null) {
            table.destroy();
            table = null;
        }
    });
});

// Data table //
// $(document).on( 'init.dt', function ( e, settings ) {
//     $('.tabledataCntrl table').wrapAll('<div class="table-responsive Custtable-responsive tableScrollbar">');
//     $('.dataTables_length').addClass('box bordered-input');
//     $('.dataTables_length select').wrapAll('<div class="dropdown-field selectTwo-dropdown">');
//     $('.dataTables_length select').addClass('basic-single');
//     $('#tabledata_filter').hide();
//     $('div.dataTables_length .basic-single').select2({
//         minimumResultsForSearch: Infinity
//     });
//     $(".tableScrollbar").mCustomScrollbar({
//         axis:"x"
//     });
// });
