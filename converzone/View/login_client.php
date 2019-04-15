<?php
    
    $email = $_POST["email"];
    $password = $_POST["password"];
    
    if(empty($email) || empty($password)){
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

    // Check if the email exists in database
    $sql = oci_parse($conn, "SELECT * FROM USERS WHERE EMAIL='".$email."'");

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
        echo json_encode(array("login_error" => "No such email address"));
        exit;
    }

    if (password_verify($password, $store_rows[0]['PASSWORD'])) {
        echo json_encode($store_rows[0]);
    } else {
        echo json_encode(array("login_error" => "Could not login in"));
    }

    //Close connection to database
    oci_close($conn);
    oci_free_statement($sql);

    // Send back token
    //  $json = array(array("password_hashed" => $password_hashed));

    //    echo json_encode($json);


    ?>

