<?php
    
    // General Information
    $firstname = $_POST["FIRSTNAME"];
    $lastname = $_POST["LASTNAME"];
    $gender = $_POST["GENDER"];
    $firstjoin = $_POST["FIRSTJOIN"];
    $birthdate = $_POST["BIRTHDATE"];
    $interests = $_POST["INTERESTS"];
    $status = $_POST["STATUS"];
    $country = $_POST["COUNTRY"];
    $pro = $_POST["PRO"];
    $discoverable = $_POST["DISCOVERABLE"];
    $notificationtoken = $_POST["NOTIFICATIONTOKEN"];
    
    $email = $_POST["EMAIL"];
    $password = $_POST["PASSWORD"];
    
    // Hash the password
    $password = password_hash($password, PASSWORD_BCRYPT);
    
    if(empty($firstname) || empty($lastname) || empty($gender) || empty($firstjoin) || empty($birthdate) || empty($email) || empty($interests) || empty($status) || empty($country) || empty($pro) || empty($discoverable) || empty($notificationtoken) || empty($email) || empty($password)){
       header("HTTP/1.0 510");
       exit;
       }
       
       // Connect to Database
       $conn = oci_connect('jeff', 'zoneconveer_2000', '10.114.57.135/XE', "'AL32UTF8'");
       if (!$conn) {
       header("HTTP/1.0 503");
       $e = oci_error();
       echo json_encode(array("oracle_connect_error" => $e['message']));
       die("Database unavailable");
       exit;
       }
       
       $sql = oci_parse($conn, "INSERT INTO USERS (PASSWORD, FIRSTNAME, LASTNAME, GENDER, FIRSTJOIN, BIRTHDATE, EMAIL, INTERESTS, STATUS, BANNED, COUNTRY, PRO, DISCOVERABLE, NOTIFICATIONTOKEN) VALUES (:password, :firstname, :lastname, :gender, TO_DATE(:firstjoin, 'yyyy-MM-dd'), TO_DATE(:birthdate, 'yyyy-MM-dd'), :email, :interests, :status, 'f', :country, :pro, :discoverable, :notificationtoken)");
                        
                        $profile_picture
                        oci_bind_by_name($sql, ':password', $password);
                        oci_bind_by_name($sql, ':firstname', $firstname);
                        oci_bind_by_name($sql, ':lastname', $lastname);
                        oci_bind_by_name($sql, ':gender', $gender);
                        oci_bind_by_name($sql, ':firstjoin', $firstjoin);
                        oci_bind_by_name($sql, ':birthdate', $birthdate);
                        oci_bind_by_name($sql, ':email', $email);
                        oci_bind_by_name($sql, ':interests', $interests);
                        oci_bind_by_name($sql, ':status', $status);
                        oci_bind_by_name($sql, ':country', $country);
                        oci_bind_by_name($sql, ':pro', $pro);
                        oci_bind_by_name($sql, ':discoverable', $discoverable);
                        oci_bind_by_name($sql, ':notificationtoken', $notificationtoken);
                        
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
    
    // Give back the new user id
    $sql = oci_parse($conn, "SELECT userid FROM USERS WHERE email = :email");
    
    oci_bind_by_name($sql, ':email', $email);
    
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
        echo json_encode($row);
        exit;
    }
    
    //Close connection to database
    oci_close($conn);
    oci_free_statement($sql);
    
    ?>






