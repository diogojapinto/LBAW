$(document).ready(function () {
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
var loadingButton = $("#getMoreProductsButton");

var loadMoreProducts = function() {
    if(!loadMore)
        return;

    loadingButton.button('loading');
    offset += productsPerBlock;
    var url = baseUrl + "actions/products/getProducts.php";

    $.get(url, {offset: offset, productName: name, productCategory: category}, function(data) {
        if( data['error'] ) {
            loadMore = false;

            loadingButton.prop('disabled', true);

            return;
        }


        if( data.length < 4 ) {
            loadMore = false;

            loadingButton.prop('disabled', true);
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

    }, 'json').always(function() {
        loadingButton.button('reset');
    });

    return;
}