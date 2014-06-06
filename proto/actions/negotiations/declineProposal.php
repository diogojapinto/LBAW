<?php

include_once('../../config/init.php');

if (!isset($_SESSION['username'])) {
    $_SESSION['error_messages'][] = 'Tem de ter sessão iniciada para rejeitar propostas';

    header("Location: $BASE_URL" . 'index.php');
    exit;
}

