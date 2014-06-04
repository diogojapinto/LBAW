$(document).ready(function () {

    $('.categoryLink').click(function () {
        var $categoryElems = $(this).parents('.btn-group');
        console.log(JSON.stringify($categoryElems, null, 4));
        $categoryElems.children('#btnCategory').text($(this).text());
        $categoryElems.children('#searchCategory').val($(this).next("span").text());
    });

    updateSizes($('.productThumbnails'));

    $(window).scroll(function() {
        if($(window).scrollTop() == $(document).height() - $(window).height())
            loadMoreProducts();
    });
});

var offset = 0;
var loadMore = true;
var baseUrl = $("input[name=baseUrl]")[0].value;
var name = $("input[name=name]")[0].value;
var category = $("input[name=category]")[0].value;
var productsPerBlock =  parseInt( $("input[name=productsPerBlock]")[0].value );
var productTemplate = Handlebars.compile($('#product-template').html());
var rowTemplate = Handlebars.compile($('#product-row-template').html());

var loadMoreProducts = function() {
    if(!loadMore)
        return;

    offset += productsPerBlock;
    var url = baseUrl + "actions/products/getProducts.php";

    $.get(url, {offset: offset, productName: name, productCategory: category}, function(data) {

        if( data['error'] ) {
            loadMore = false;

            $("#getMoreProducts button").prop('disabled', true);

            return;
        }


        if( data.length < 4 ) {
            loadMore = false;

            $("#getMoreProducts button").prop('disabled', true);
        }

        var i = 0, products = [];
        $.each(data, function(key, value) {
            products[i] = productTemplate(value);

            if( i++ == 3 ) {
                $(rowTemplate({products: products})).insertAfter($("#productsList > div:last-child"));
                updateSizes($("#productsList > div:last-child"));

                i = 0;
            }
        });

        if( i != 0 ) {
            $(rowTemplate({products: products})).insertAfter($("#productsList > div:last-child"));
            updateSizes($("#productsList > div:last-child"));
        }

    }, 'json');

}

var updateSizes = function(row) {
    row.each(function () {

        var max = -1;

        var $thumbnail = $(this).find('a > div > div');

        $thumbnail.each(function () {
            console.log(max + " " + $(this).height());
            max = $(this).height() > max ? $(this).height() : max;
        });

        $thumbnail.each(function () {
            $(this).css('height', max);
        });

        console.log(max);
    });
}