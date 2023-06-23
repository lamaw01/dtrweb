<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// last output
$result_array = array();

// if not put id die
if($_SERVER['REQUEST_METHOD']){
    $date_from = $input['date_from'];
    $date_to = $input['date_to'];

    $sql_get_history_all = "SELECT tbl_logs.id, tbl_logs.employee_id, tbl_employee.name, 
    DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') time_stamp FROM tbl_logs 
    LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    WHERE tbl_logs.time_stamp BETWEEN :date_from AND :date_to AND tbl_employee.name IS NOT NULL
    GROUP BY tbl_logs.employee_id, DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') ORDER BY tbl_logs.id ASC;";

    try {
        $get_history_all= $conn->prepare($sql_get_history_all);
        $get_history_all->bindParam(':date_from', $date_from, PDO::PARAM_STR);
        $get_history_all->bindParam(':date_to', $date_to, PDO::PARAM_STR);
        $get_history_all->execute();
        $result_get_history_all = $get_history_all->fetchAll(PDO::FETCH_ASSOC);
        foreach ($result_get_history_all as $result) {
            $id = $result['employee_id'];
            $time_head = $result['time_stamp'];
            $time_tail = $result['time_stamp'];
            // get logs
            $get_logs_within= $conn->prepare("SELECT case is_selfie when '0' then time_stamp when '1' then selfie_timestamp end time_stamp,
            log_type, id, is_selfie FROM tbl_logs
            WHERE employee_id = :id AND time_stamp BETWEEN '$time_head 00:00:00' AND '$time_tail 23:59:59' LIMIT 6;");
            $get_logs_within->bindParam(':id', $id, PDO::PARAM_STR);
            $get_logs_within->execute();
            $result_get_logs_within = $get_logs_within->fetchAll(PDO::FETCH_ASSOC);
            $my_array = array('employee_id'=>$result['employee_id'],'name'=>$result['name'],'date'=>$result['time_stamp'],'logs'=>$result_get_logs_within);
            array_push($result_array,$my_array);
        }
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