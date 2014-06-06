<?php
    include_once('../../config/init.php');
    include_once($BASE_DIR . 'pages/common/initializer.php');
    include_once($BASE_DIR . 'database/users.php');
    include_once($BASE_DIR . 'database/products.php');

    if (isSeller($_GET['seller'])) {
        $idSeller = getIdUser($_GET['seller']);
        $seller = getSeller($idSeller);
        $products = getProductsBySeller($idSeller);
        shuffle($products);
        $products = array_slice($products, 0, 4);
        $smarty->assign('USERNAME', $_GET['seller']);
        $smarty->assign('SELLER', $seller);
        $smarty->assign('PRODUCTS', $products);
        $smarty->display('users/sellerPage.tpl');
    } else {
        $_SESSION['error_messages'] = array('Esse utilizador não é vendedor.');

        header('Location: ' . $BASE_URL);
        exit;
    }
?>