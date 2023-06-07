<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// last output
$result_array = array();

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('employee_id', $input)){
    $employee_id = $input['employee_id'];
    $date_from = $input['date_from'];
    $date_to = $input['date_to'];

    // get query between dates
    // $sql_get_history = "SELECT tbl_logs.employee_id, tbl_employee.name, DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') time_stamp 
    // FROM tbl_logs LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    // WHERE (tbl_logs.employee_id = :employee_id OR tbl_employee.name LIKE '%:employee_id%') AND tbl_logs.time_stamp 
    // BETWEEN '$date_from 00:00:00' AND '$date_to 23:59:59' GROUP BY DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') LIMIT 30;";

    // $sql_get_logs_within_date = "SELECT time_stamp FROM tbl_logs
    // WHERE employee_id = '01152'
    // AND time_stamp BETWEEN '2023-05-30 00:00:00' AND '2023-05-30 23:59:59'";

    $sql_get_history = "SELECT tbl_logs.employee_id, tbl_employee.name, DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') time_stamp 
    FROM tbl_logs LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    WHERE (tbl_logs.employee_id LIKE '%$employee_id%' OR tbl_employee.name LIKE '%$employee_id%') 
    AND tbl_logs.time_stamp BETWEEN '$date_from' AND '$date_to' GROUP BY DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') LIMIT 30;";

    $sql_get_history_all = "SELECT tbl_logs.employee_id, tbl_employee.name, 
    DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') time_stamp FROM tbl_logs 
    LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    WHERE tbl_logs.time_stamp BETWEEN '$date_from' AND '$date_to' AND tbl_employee.name IS NOT NULL
    GROUP BY tbl_logs.employee_id, DATE_FORMAT(tbl_logs.time_stamp, '%Y-%m-%d') ORDER BY tbl_logs.id DESC LIMIT 30;";

    try {
        if($employee_id == 'all'){
            $get_history= $conn->prepare($sql_get_history_all);
        }else{
            $get_history= $conn->prepare($sql_get_history);
        }
        $get_history->bindParam(':employee_id', $employee_id, PDO::PARAM_STR);
        $get_history->execute();
        $result_get_history = $get_history->fetchAll(PDO::FETCH_ASSOC);
        foreach ($result_get_history as $result) {
            $time_head = $result['time_stamp'];
            $time_tail = $result['time_stamp'];
            $id = $result['employee_id'];
            // get logs
            $get_logs_within= $conn->prepare("SELECT time_stamp, log_type, id, is_selfie FROM tbl_logs
            WHERE employee_id = :employee_id
            AND time_stamp BETWEEN '$time_head 00:00:00' AND '$time_tail 23:59:59' LIMIT 6;");
            $get_logs_within->bindParam(':employee_id', $id, PDO::PARAM_STR);
            $get_logs_within->execute();
            $result_get_logs_within = $get_logs_within->fetchAll(PDO::FETCH_ASSOC);
            // get image
            // $get_image_within= $conn->prepare("SELECT id, selfie_timestamp FROM tbl_logs WHERE employee_id = :employee_id
            // AND is_selfie = 1 AND time_stamp BETWEEN '$time_head 00:00:00' AND '$time_tail 23:59:59' LIMIT 6;");
            // $get_image_within->bindParam(':employee_id', $id, PDO::PARAM_STR);
            // $get_image_within->execute();
            // $result_get_image_within = $get_image_within->fetchAll(PDO::FETCH_ASSOC);
            // // array of log
            // $array_log = array('time'=>$result_get_logs_within,'image'=>$result_get_image_within);
            // array_push($array_log,);
            // insert array
            $my_array = array('employee_id'=>$result['employee_id'],'name'=>$result['name'],'date'=>$result['time_stamp'],'logs'=>$result_get_logs_within);
            //$my_array = array('employee_id'=>$result['employee_id'],'name'=>$result['name'],'date'=>$result['time_stamp'],'image'=>$result_get_image_within,'logs'=>$result_get_logs_within);
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