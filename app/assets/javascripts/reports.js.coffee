# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  historyTableDiv = $('#history-table')
  console.log('History table')
  # If we actually have a history table element, fire up the DataTables JS
  if historyTableDiv.length
    historyTableDiv.DataTable(
      paging: true
    );

$(document).ready(ready)
$(document).on('page:load', ready)
