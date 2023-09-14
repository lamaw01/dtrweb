<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'GET'){

    $sql_get_schedule = "SELECT tbl_schedule.sched_id, tbl_schedule.sched_type, tbl_schedule.sched_in, tbl_schedule.break_start, tbl_schedule.break_end, tbl_schedule.sched_out, tbl_schedule.description
    FROM tbl_schedule ORDER BY tbl_schedule.sched_id";

    try {
        $get_schedule= $conn->prepare($sql_get_schedule);
        $get_schedule->execute();
        $result_get_schedule = $get_schedule->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($result_get_schedule);
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