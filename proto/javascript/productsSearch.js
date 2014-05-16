$(document).ready(function () {

    $('.categoryLink').click(function () {
        $('#btnCategory').text($(this).text());
        $('#searchCategory').val($(this).next("span").text());
    });


    $('.productThumbnails').each(function () {

        var max = -1;

        var $thumbnail = $(this).find('a > div > div');

        $thumbnail.each(function () {
            max = $(this).height() > max ? $(this).height() : max;
        });

        $thumbnail.each(function () {
            $(this).css('height', max);
        });
    });
});