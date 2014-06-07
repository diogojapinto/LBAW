var baseUrl = $("input[name=baseUrl]")[0].value;
var getNotificationsUrl = baseUrl + "actions/users/getNotifications.php";
var interactionTemplate = Handlebars.compile($('#interaction-template').html());
var privateMessageTemplate = Handlebars.compile($('#privateMessage-template').html());

$(document).ready(function() {
    $("#showAllNotifications").click(function() {
        window.location.href = baseUrl + "pages/users/shownotifications.php";
    });

    setInterval(updateNotifications, 10000);
});

function updateNotifications() {
    $.get(getNotificationsUrl, function(data) {
        if( data['error'] )
            return;

        $("#notificationsHeaderList li:not(.divider)").remove();

        var count = parseInt( data['count'] );
        if( count == 0 )
            $("#sessionLink span.badge").remove();
        else
            $("#sessionLink span.badge").text(count);

        console.log(data);

        $.each( data['privateMessages'], function(key, value) {
            console.log(value);
            $("#firstDivider").after( privateMessageTemplate({number: key + 1, subject: value['subject']}) );
        });

        $.each( data['interactions'], function(key, value) {
            console.log(value);
            $("#notificationsHeaderList").prepend( interactionTemplate(value) );
        });

    }, 'json');
}