$(document).ready(function () {

    $('.categoryLink').click(function () {
        var $categoryElems = $(this).parents('.btn-group');
        console.log(JSON.stringify($categoryElems, null, 4));
        $categoryElems.children('#btnCategory').text($(this).text());
        $categoryElems.children('#searchCategory').val($(this).next("span").text());
    });

    updateSizes();

    $(window).scroll(function() {
        if($(window).scrollTop() == $(document).height() - $(window).height())
            loadMoreProducts();
    });
});

var offset = 0;
var baseUrl = $("input[name=baseUrl]")[0].value;
var productsPerBlock =  parseInt( $("input[name=productsPerBlock]")[0].value );
var productTemplate = Handlebars.compile($('#product-template').html());
var rowTemplate = Handlebars.compile($('#product-row-template').html());

var loadMoreProducts = function() {
    offset += productsPerBlock;
    var url = baseUrl + "actions/products/getProducts.php";

    $.get(url, {offset: offset}, function(data) {
        var i = 0, products = [];
        $.each(data, function(key, value) {
            products[i] = productTemplate(value);

            if( i++ == 3 ) {
                $(rowTemplate({products: products})).insertAfter($("#productsList > div:nth-last-child(2)"));
                i = 0;
            }
        });
    }, 'json');

    updateSizes();
}

var updateSizes = function() {
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
}