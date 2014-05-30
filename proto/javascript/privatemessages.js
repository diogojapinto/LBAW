$(document).ready(function() {
   $("#privateMessagesTable tbody tr.privateMessage").click(function() {
       var id = $(this).children().first().text();
       var type = $(this).children(":not(:first-child)").first().text();

       if(!$(this).next().children().first().hasClass("privateMessageContent"))
        $($("<tr><td class='privateMessageContent' colspan='3'>"+'Cenas'+"</td></tr>"))
            .insertAfter($(this));



   });
});

