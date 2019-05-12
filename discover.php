<?php
    
    $min_id = $_POST["min_id"];
    $max_id = $_POST["max_id"];
    
    if(empty($min_id) || empty($max_id)){
        header("HTTP/1.0 510");
        exit;
    }
    
    // Connect to Database
    $conn = oci_connect('jeff', 'zoneconveer_2000', 'localhost/XE');
    if (!$conn) {
        header("HTTP/1.0 503");
        $e = oci_error();
        echo json_encode(array("oracle_connect_error" => $e['message']));
        die("Database unavailable");
        exit;
    }
    
    $sql = oci_parse($conn, "SELECT FIRSTNAME FROM USERS WHERE USERID >='".$min_id."' AND USERID <='".$max_id."'");
    
    if (!$sql) {
        // Replace "517" with something suitable
        header("HTTP/1.0 517");
        $e = oci_error($sql);
        echo json_encode(array("oracle_parse_error" => $e["message"]));
        exit;
    }
    
    $query = oci_execute($sql);
    
    if (!$query) {
        header("HTTP/1.0 519");
        $e = oci_error($sql);
        echo json_encode(array("oracle_execute_error" => $e["message"]));
        exit;
    }
    
    $store_rows = array();
    while ($row = oci_fetch_array($sql, OCI_ASSOC+OCI_RETURN_NULLS)) {
        array_push($store_rows, $row);
    }
    
    if (empty($store_rows[0])){
        header("HTTP/1.0 520");
        echo json_encode(array("discover_error" => "No users in the database"));
        exit;
    }
    
    echo json_encode($store_rows);
    
    //Close connection to database
    oci_close($conn);
    oci_free_statement($sql);
    
?>
