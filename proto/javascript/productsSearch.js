/**
 * Created by knoweat on 24/04/14.
 */
$(document).ready(function () {
    $('.categoryLink').click(function() {
        $('#btnCategory').text($(this).text());
    });
});