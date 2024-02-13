<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'GET'){

    $sql_get_settings = "SELECT late_threshold FROM tbl_settings WHERE id = 1;";

    try {
        $get_settings= $conn->prepare($sql_get_settings);
        $get_settings->execute();
        $result_get_settings = $get_settings->fetch(PDO::FETCH_ASSOC);
        echo json_encode($result_get_settings);
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}
else{
    echo json_encode(array('success'=>false,'message'=>'Error input'));
    die();
}
?>