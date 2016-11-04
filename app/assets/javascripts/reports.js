// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

class DataTableStyling {
    static applyStyling() {
        let infoDiv = $('#history-table_info');
        infoDiv.addClass('street-fighter');
        infoDiv.addClass('data-table-info');
        let paginationButtons = $('.paginate_button');
        paginationButtons.addClass('street-fighter');
        paginationButtons.addClass('data-table-info');
    }
}

/**
 * Initialize page on load
 */
$(document).ready( function() {
    console.log('reports JS init');
    let historyTableDiv = $('#history-table')

    if (pageType == 'history_table') {
        // If we actually have a history table element, fire up the DataTables JS
        if (historyTableDiv.length) {
            historyTableDiv.DataTable({
                paging: true
            });
        }
        DataTableStyling.applyStyling();
    }
});
