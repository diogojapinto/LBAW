<!DOCTYPE html>
<html>

<head>
    <title>Realezy - Realize os seus desejos, "the easy way"</title>
    <meta content="text/html, charset=iso-8859-1" name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link href="{$BASE_URL}css/bootstrap.min.css" rel="stylesheet"/>
    <link href="{$BASE_URL}css/styles.css" rel="stylesheet"/>
    <link rel="icon" type="image/png" href="{$BASE_URL}images/icon_set/icon.png"/>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js" type="text/javascript"></script>
    <script src="{$BASE_URL}javascript/handlebars-v1.3.0.js" type="text/javascript"></script>
    <script src="{$BASE_URL}javascript/productsSearch.js" type="text/javascript"></script>
</head>

<body>

<div class="navbar navbar-inverse navbar-static-desktop">

    <div class="container">

        <div class="row">
            <div class="col-md-2">
                <a class="navbar-brand" href="{$BASE_URL}">
                    <img class="img-responsive" style="margin-top:-12px;"
                         src="{$BASE_URL}images/icon_set/logo.png" height="40"
                         width="100"
                         alt="Realezy Logo"/>
                </a>
            </div>

            <!--<button class="navbar-toggle" data-toggle="collapse" data-target=".navHeaderCollapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>-->
            <!-- <div class="container collapse navbar-collapse navHeaderCollapse" style="margin-top:7px"> -->
            <div class="container" style="margin-top:7px">
                <form method="post" action="{$BASE_URL}pages/products/search.php">
                    <div class="container col-md-7">
                        <div class="col-md-2">

                        </div>
                        <div class="col-md-6 navbar-search searchText">
                            <input type="text" name="productName" value="{$FORM_VALUES.name}" placeholder="Produto"
                                   class="form-control"/>
                        </div>
                        <div class="col-md-4 searchButtons">
                            <div class="btn-group">
                                <button id="btnCategory" type="button" class="btn btn-danger" data-toggle="dropdown">
                                    Categorias
                                </button>
                                <button type="button" style="z-index:1" class="btn btn-danger dropdown-toggle"
                                        data-toggle="dropdown">
                                    <span class="caret"></span>
                                    <span class="sr-only">Toggle Dropdown</span>
                                </button>
                                <ul class="dropdown-menu" role="menu">
                                    {foreach $baseCategories as $baseCategory}
                                        <li>
                                            <a href="#" class="categoryLink">{$baseCategory.name}</a>
                                            <span style="display: none">{$baseCategory.idcategory}</span>
                                        </li>
                                    {/foreach}
                                </ul>
                                <input type="hidden" id="searchCategory" name="productCategory" value="All">
                                <button style="z-index:0;left:-4px;border-top-right-radius:4px; border-bottom-right-radius:4px;"
                                        class="btn btn-success" id="coiso">
                                    <span class="glyphicon glyphicon-search"></span>
                                </button>
                            </div>
                            <!--<a data-toggle="modal" id="advSearchBtn" href="#advSearch" class="btn">Pesquisa
                                Avan&ccedil;ada</a>-->
                        </div>
                    </div>
                </form>
                {if $USERNAME}
                    {include file='common/menu_logged_in.tpl'}
                {else}
                    {include file='common/menu_logged_out.tpl'}
                {/if}
            </div>
        </div>
    </div>
</div>
<div class="errorsParent">
    {foreach $ERROR_MESSAGES as $ERROR}
        <div class="alert alert-danger errorsAlert">{$ERROR}</div>
    {/foreach}
    {foreach $SUCCESS_MESSAGES as $SUCCSESS}
        <div class="alert alert-success errorsAlert">{$SUCCSESS}</div>
    {/foreach}
</div>
<div class="dynamicErrorsParent">
</div>
