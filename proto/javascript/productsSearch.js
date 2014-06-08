$(document).ready(function () {

    $('.categoryLink').click(function () {
        var $categoryElems = $(this).parents('.btn-group');
        console.log(JSON.stringify($categoryElems, null, 4));
        $categoryElems.children('#btnCategory').text($(this).text());
        $categoryElems.children('#searchCategory').val($(this).next("span").text());
    });

    updateSizes($('.productThumbnails'));

});

var updateSizes = function(row) {
    row.each(function () {

        var max = -1;

        var $thumbnail = $(this).find('a > div > div');

        $thumbnail.each(function () {
            max = $(this).height() > max ? $(this).height() : max;
        });

        $thumbnail.each(function () {
            $(this).css('height', max);
        });

    });
}