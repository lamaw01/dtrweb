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
    $department = $input['department'];

    $concat_employee_id = "%$employee_id%";

    $sql_get_history = "SELECT tbl_logs.id, tbl_logs.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, 
    tbl_employee.week_sched_id, tbl_logs.current_sched_id,
    DATE_FORMAT((case is_selfie when 0 then time_stamp when 1 then selfie_timestamp end), '%Y-%m-%d') time_stamp 
    FROM tbl_logs LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    LEFT JOIN tbl_week_schedule ON tbl_employee.week_sched_id = tbl_week_schedule.week_sched_id 
    WHERE (tbl_logs.employee_id LIKE :employee_id OR tbl_employee.first_name LIKE :employee_id OR tbl_employee.last_name LIKE :employee_id) 
    AND tbl_employee.last_name IS NOT NULL AND (case tbl_logs.is_selfie when 0 then tbl_logs.time_stamp when 1 then tbl_logs.selfie_timestamp end) BETWEEN :date_from AND :date_to GROUP BY DATE_FORMAT((case tbl_logs.is_selfie when 0 then tbl_logs.time_stamp when 1 then tbl_logs.selfie_timestamp end), '%Y-%m-%d') ORDER BY tbl_logs.id ASC;";

    //AND tbl_employee.last_name IS NOT NULL

    $sql_get_history_with_department = "SELECT tbl_logs.id, tbl_logs.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, 
    tbl_employee.week_sched_id, tbl_logs.current_sched_id,
    DATE_FORMAT((case is_selfie when 0 then time_stamp when 1 then selfie_timestamp end), '%Y-%m-%d') time_stamp 
    FROM tbl_logs LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    LEFT JOIN tbl_employee_department ON tbl_employee.employee_id = tbl_employee_department.employee_id 
    LEFT JOIN tbl_week_schedule ON tbl_employee.week_sched_id = tbl_week_schedule.week_sched_id 
    WHERE (tbl_logs.employee_id LIKE :employee_id OR tbl_employee.first_name LIKE :employee_id OR tbl_employee.last_name LIKE :employee_id) 
    AND tbl_employee.last_name IS NOT NULL AND (case tbl_logs.is_selfie when 0 then tbl_logs.time_stamp when 1 then tbl_logs.selfie_timestamp end) BETWEEN :date_from AND :date_to AND tbl_employee_department.department_id = :department 
    GROUP BY DATE_FORMAT((case tbl_logs.is_selfie when 0 then tbl_logs.time_stamp when 1 then tbl_logs.selfie_timestamp end), '%Y-%m-%d') ORDER BY tbl_logs.id ASC;";

    try {
        $set=$conn->prepare("SET SQL_MODE=''");
        $set->execute();
        
        if($department != '000'){
            $get_history=$conn->prepare($sql_get_history_with_department);
        }else{
            $get_history=$conn->prepare($sql_get_history);
        }
        $get_history->bindParam(':employee_id', $concat_employee_id, PDO::PARAM_STR);
        $get_history->bindParam(':date_from', $date_from, PDO::PARAM_STR);
        $get_history->bindParam(':date_to', $date_to, PDO::PARAM_STR);
        if($department != '000'){
            $get_history->bindParam(':department', $department, PDO::PARAM_STR);
        }
        $get_history->execute();
        $result_get_history = $get_history->fetchAll(PDO::FETCH_ASSOC);
        foreach ($result_get_history as $result) {
            $id = $result['employee_id'];
            $time_head = $result['time_stamp'];
            $time_tail = $result['time_stamp'];
            // get logs
            $get_logs_within= $conn->prepare("SELECT case is_selfie when 0 then time_stamp when 1 then selfie_timestamp end time_stamp,
            log_type, id, image_path, is_selfie FROM tbl_logs
            WHERE employee_id = :id AND (case is_selfie when 0 then time_stamp when 1 then selfie_timestamp end) BETWEEN '$time_head 00:00:00' AND '$time_tail 23:59:59' LIMIT 6;");
            $get_logs_within->bindParam(':id', $id, PDO::PARAM_STR);
            $get_logs_within->execute();
            $result_get_logs_within = $get_logs_within->fetchAll(PDO::FETCH_ASSOC);
            $my_array = array('employee_id'=>$result['employee_id'],'first_name'=>$result['first_name'] ?? 'NA','last_name'=>$result['last_name'] ?? 'NA','middle_name'=>$result['middle_name'] ?? 'NA','date'=>$result['time_stamp'],'logs'=>$result_get_logs_within,'week_sched_id'=>$result['week_sched_id'],'current_sched_id'=>$result['current_sched_id']);
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