<?php
    
    $id = $_POST["id"];
    
    if(empty($id)){
        header("HTTP/1.0 510");
        exit;
    }
    
    echo json_encode(array("this is text"=>"it is!"))
    
    // Connect to Database
    $conn = oci_connect('jeff', 'zoneconveer_2000', '10.114.57.135/XE');
    if (!$conn) {
        header("HTTP/1.0 503");
        $e = oci_error();
        echo json_encode(array("oracle_connect_error" => $e['message']));
        die("Database unavailable");
        exit;
    }
    
    $sql = oci_parse($conn, "SELECT * FROM LANGUAGEPROFICIENCIES WHERE USERID = $id ");
    
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
    
    while ($row = oci_fetch_array($sql, OCI_ASSOC+OCI_RETURN_NULLS)) {
       echo json_encode($store_rows);
        exit;
    }
    
    header("HTTP/1.0 520");
    echo json_encode(array("discover_error" => "No users in the database"));
    
    //Close connection to database
    oci_close($conn);
    oci_free_statement($sql);
    
    ?>
