<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// last output
$result_array = array('count'=>0);

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('employee_id', $input)){
    $employee_id = $input['employee_id'];
    $date_from = $input['date_from'];
    $date_to = $input['date_to'];

    $concat_employee_id = "%$employee_id%";

    $sql_get_history = "SELECT COUNT(*) as count FROM tbl_logs 
    LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    WHERE (tbl_logs.employee_id LIKE :employee_id OR tbl_employee.name LIKE :employee_id) 
    AND tbl_logs.time_stamp BETWEEN :date_from AND :date_to GROUP BY DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d');";

    try {
        $get_history_count= $conn->prepare($sql_get_history);
        $get_history_count->bindParam(':employee_id', $concat_employee_id, PDO::PARAM_STR);
        $get_history_count->bindParam(':date_from', $date_from, PDO::PARAM_STR);
        $get_history_count->bindParam(':date_to', $date_to, PDO::PARAM_STR);
        $get_history_count->execute();
        $result_array['count'] = $get_history_count->rowCount();
        echo json_encode($result_array);
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