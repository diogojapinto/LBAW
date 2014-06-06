/**
 * Created by knoweat on 02/05/14.
 */

$(document).ready(function () {
    $('.errorsAlert').delay(2000).slideUp(600);
});

var errorsParent = $('div.dynamicErrorsParent');
var errorTemplate = Handlebars.compile($('#error-template').html());
var showError = function(text, type) {
    if(type !== 'danger' && type !== 'success')
        return;

    errorsParent.append($(errorTemplate({type: type, text:text}))).slideDown(600);
    errorsParent.delay(2000).slideUp(600, function() {
        $(this).children().remove();
    });
}