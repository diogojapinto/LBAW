$(document).ready(function () {
    var template = Handlebars.compile($('#privatemessage-template').html());

    $("#privateMessagesTable tbody tr.privateMessage").click(function () {
        var id = $(this).children().first().text();

        //Not used but may be needed in the future
        //var type = $(this).children(":not(:first-child)").first().text();

        if (!$(this).next().children().first().hasClass("privateMessageContent"))
            getAndInsertPrivateMessage($(this), template, id);
        else {
            $(this).find("span.caret").css({'-webkit-transform': 'rotate(-90deg)',
                                            'transform': 'rotate(-90deg)',
                                            '-ms-transform': 'rotate(-90deg)'});

            $(this).next().children().remove();
        }
    });
});

var getAndInsertPrivateMessage = function(row, template, id) {
    var context = {content: 'yes bro'};
    var url = $("input[name=baseUrl]")[0].value + "actions/users/getPrivateMessage.php";

    $.get(url, {idPrivateMessage: id}, function(data) {
        $(template(data))
            .insertAfter(row);

        row.find("span.caret").css({'-webkit-transform': 'rotate(0deg)',
                                    'transform': 'rotate(0deg)',
                                    '-ms-transform': 'rotate(0deg)'});
        
        row.removeClass("bg-danger").addClass("bg-success");
    });
}