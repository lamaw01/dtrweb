<?php
require '../db_connect.php';
header("Content-type: image/jpeg");

$id = $_GET['id'];

// query select image
$sql_get_image = 'SELECT image from tbl_logs
WHERE id = :id';

try {
    $get_image = $conn->prepare($sql_get_image);
    $get_image->bindParam(':id', $id, PDO::PARAM_STR);
    $get_image->execute();
    $result_get_image = $get_image->fetch(PDO::FETCH_ASSOC);
    $code_base64 = $result_get_image['image'];
    $code_base64 = str_replace('data:image/jpeg;base64,','',$code_base64);
    $code_binary = base64_decode($code_base64);
    $image2= imagecreatefromstring($code_binary);
    imagejpeg($image2);
    imagedestroy($image2);
} catch (PDOException $e) {
    echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
} finally{
    // Closing the connection.
    $conn = null;
}

?>