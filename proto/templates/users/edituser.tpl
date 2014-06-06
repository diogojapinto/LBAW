{include file='common/header.tpl'}

{if $USERTYPE != 'buyer'}
    {include file='users/editseller.tpl'}
{else}
    {include file='users/editbuyer.tpl'}
{/if}

{include file='common/footer.tpl'}
<script>
    $(document).ready(function() {
        $("button[data-toggle=tooltip").tooltip();
    });
</script>