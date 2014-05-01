<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">

<head>
    <title>Realezy - Realize os seus desejos, "the easy way"</title>
    <meta content="text/html; charset=iso-8859-1" name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="{$BASE_URL}css/bootstrap.min.css" rel="stylesheet">
    <link href="{$BASE_URL}css/styles.css" rel="stylesheet">
</head>

<body>

<div class="navbar navbar-inverse navbar-static-desktop">

    <div class="container">

        <div class="row">
            <div class="col-md-2">
                <a class="navbar-brand" href="{$BASE_URL}">
                    <img class="img-responsive" style="margin-top:-12px;"
                         src="{$BASE_URL}images/icon_set/logo.png" height="40px"
                         width="100px"
                         alt="Realezy Logo"/>
                </a>
            </div>

            <button class="navbar-toggle" data-toggle="collapse" data-target=".navHeaderCollapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>

            <div class="container collapse navbar-collapse navHeaderCollapse" style="margin-top:7px">
                <form role="form" method="post" action="{$BASE_URL}pages/products/search.php">
                <div class="container col-md-8">
                    <div class="col-md-6 navbar-search">
                        <input type="text" value="{$FORM_VALUES.name}" placeholder="Produto" class="form-control">
                    </div>
                    <div class="col-md-6">
                        <div class="btn-group">
                            <button id="btnCategory" type="button" class="btn btn-danger" data-toggle="dropdown">
                                Categorias
                            </button>
                            <button type="button" style="z-index:1" class="btn btn-danger dropdown-toggle"
                                    data-toggle="dropdown">
                                <span class="caret"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                            <select name="category" class="dropdown-menu" role="menu">
                                <option value="null"><a href="#"> Categorias </a></option>
                                {foreach $baseCategories as $baseCategory}
                                    <option value="{$baseCategory.idCategory}">{$baseCategory.name}</option>
                                {/foreach}
                            </select>
                            <button type="submit"
                                    style="z-index:0;left:-4px;border-top-right-radius:4px; border-bottom-right-radius:4px;"
                                    class="btn btn-success">
                                <span class="glyphicon glyphicon-search"></span>
                                <span class="sr-only">Toggle Dropdown</span>
                            </button>
                        </div>
                        <a data-toggle="modal" id="advSearchBtn" href="#advSearch" class="btn">Pesquisa
                            Avan&ccedil;ada</a>
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