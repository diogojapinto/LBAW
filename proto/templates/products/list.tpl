
{include file='common/header.tpl'}
<section id="products">
  <h2>Products</h2>

  <div id="top_products"></div>

  {foreach $products as $product}

  <article class="product-data">
    <img src="{$BASE_URL}/images/{$product.idproduct}">
    <span class="realname">{$product.name}</span>
    <a href="{$BASE_URL}pages/products/product.php?productId={$product.idproduct}">@{$product.name}</a>

    <span class="time">{$product.description}</span>
  </article>

  {/foreach}

</section>

{include file='common/footer.tpl'}
