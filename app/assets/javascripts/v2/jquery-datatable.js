$(function () {
    $('.js-basic-example').DataTable({
        conditionalPaging: true,
        responsive: true
    });

    //Exportable table
    $('.js-exportable').DataTable({
        conditionalPaging: true,
        dom: 'Bfrtip',
        responsive: true,
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ]
    });
});
