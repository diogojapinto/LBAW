var baseUrl = $("input[name=baseUrl]")[0].value;

$(document).ready(function() {
    $("#showAllNotifications").click(function() {
        window.location.href = baseUrl + "pages/users/shownotifications.php";
    });

    setInterval(updatePrivateMessages, 10000);
});

function updatePrivateMessages() {

}