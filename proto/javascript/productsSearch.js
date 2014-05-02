/**
 * Created by knoweat on 24/04/14.
 */

var selectedCat;

$(document).ready(function () {
    $('.categoryLink').click(function() {
        selectedCat = $(this).text();
        $('#btnCategory').text($(this).text());
    });
});