<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

//INSERT INTO `tbl_week_schedule`(`week_sched_id`, `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`) 
//VALUES ('IT-M','M-B-85','M-B-85','M-B-85','M-B-85','M-B-85','M-B-85','DAY-OFF');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// last output
$result_array = array();

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'POST'){
    $date_from = $input['date_from'];
    $date_to = $input['date_to'];
    $department = $input['department'];

    $sql_get_history_all = "SELECT tbl_logs.id, tbl_logs.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name,
    tbl_employee.week_sched_id, tbl_week_schedule.monday, tbl_week_schedule.tuesday, tbl_week_schedule.wednesday, tbl_week_schedule.thursday, tbl_week_schedule.friday, tbl_week_schedule.saturday, tbl_week_schedule.sunday,
    DATE_FORMAT(selfie_timestamp, '%Y-%m-%d') selfie_timestamp FROM tbl_logs 
    LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    LEFT JOIN tbl_week_schedule ON tbl_employee.week_sched_id = tbl_week_schedule.week_sched_id 
    WHERE  tbl_logs.selfie_timestamp BETWEEN :date_from AND :date_to AND tbl_employee.last_name IS NOT NULL
    GROUP BY tbl_logs.employee_id, DATE_FORMAT(tbl_logs.selfie_timestamp, '%Y-%m-%d') ORDER BY tbl_logs.id ASC;";

    //AND tbl_employee.last_name IS NOT NULL

    $sql_get_history_all_with_department = "SELECT tbl_logs.id, tbl_logs.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, 
    tbl_employee.week_sched_id, tbl_week_schedule.monday, tbl_week_schedule.tuesday, tbl_week_schedule.wednesday, tbl_week_schedule.thursday, tbl_week_schedule.friday, tbl_week_schedule.saturday, tbl_week_schedule.sunday,
    DATE_FORMAT(selfie_timestamp, '%Y-%m-%d') selfie_timestamp FROM tbl_logs 
    LEFT JOIN tbl_employee ON tbl_logs.employee_id = tbl_employee.employee_id 
    LEFT JOIN tbl_employee_department ON tbl_employee.employee_id = tbl_employee_department.employee_id 
    LEFT JOIN tbl_week_schedule ON tbl_employee.week_sched_id = tbl_week_schedule.week_sched_id 
    WHERE tbl_logs.selfie_timestamp BETWEEN :date_from AND :date_to AND tbl_employee_department.department_id = :department AND tbl_employee.last_name IS NOT NULL
    GROUP BY tbl_logs.employee_id, DATE_FORMAT(tbl_logs.selfie_timestamp, '%Y-%m-%d') ORDER BY tbl_logs.id ASC;";

    try {
        $set=$conn->prepare("SET SQL_MODE=''");
        $set->execute();
        
        if($department != '000'){
            $get_history_all=$conn->prepare($sql_get_history_all_with_department);
        }else{
            $get_history_all=$conn->prepare($sql_get_history_all);
        }
        $get_history_all->bindParam(':date_from', $date_from, PDO::PARAM_STR);
        $get_history_all->bindParam(':date_to', $date_to, PDO::PARAM_STR);
        if($department != '000'){
            $get_history_all->bindParam(':department', $department, PDO::PARAM_STR);
        }
        $get_history_all->execute();
        $result_get_history_all = $get_history_all->fetchAll(PDO::FETCH_ASSOC);
        foreach ($result_get_history_all as $result) {
            $id = $result['employee_id'];
            $time_head = $result['selfie_timestamp'];
            $time_tail = $result['selfie_timestamp'];
            // get logs
            $get_logs_within= $conn->prepare("SELECT selfie_timestamp as time_stamp,
            log_type, id, is_selfie FROM tbl_logs
            WHERE employee_id = :id AND selfie_timestamp BETWEEN '$time_head 00:00:00' AND '$time_tail 23:59:59' LIMIT 6;");
            $get_logs_within->bindParam(':id', $id, PDO::PARAM_STR);
            $get_logs_within->execute();
            $result_get_logs_within = $get_logs_within->fetchAll(PDO::FETCH_ASSOC);
            $my_array = array('employee_id'=>$result['employee_id'],'first_name'=>$result['first_name'] ?? 'NA','last_name'=>$result['last_name'] ?? 'NA','middle_name'=>$result['middle_name'] ?? 'NA','date'=>$result['selfie_timestamp'],'logs'=>$result_get_logs_within,'week_sched_id'=>$result['week_sched_id'] ?? 'NA','monday'=>$result['monday'] ?? 'NA','tuesday'=>$result['tuesday'] ?? 'NA','wednesday'=>$result['wednesday'] ?? 'NA','thursday'=>$result['thursday'] ?? 'NA','friday'=>$result['friday']?? 'NA','saturday'=>$result['saturday'] ?? 'NA','sunday'=>$result['sunday'] ?? 'NA');
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
