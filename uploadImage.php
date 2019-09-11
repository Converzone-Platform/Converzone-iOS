<?php
    
    $target_dir = "/var/www/html/profile_images/";
    $target_file = $target_dir . basename($_FILES["uploaded_file"]["name"]);
    $uploadOk = 1;
    $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
    
    // If the user file already exists, delete it
    if (file_exists($target_file)) unlink($target_file);

    // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
        echo "Sorry, your file was not uploaded.";
        // if everything is ok, try to upload file
    } else {
        if (move_uploaded_file($_FILES["uploaded_file"]["tmp_name"], $target_file)) {
            //echo "The file ". basename( $_FILES["uploaded_file"]["name"]). " has been uploaded.";
        } else {
            echo "Sorry, there was an error uploading your file.";
        }
    }
    
    // General Information
    $id = $_FILES["USERID"];
    
//    if(empty($id)){
//        header("HTTP/1.0 510");
//        exit;
//    }
    
    // Connect to Database
    $conn = oci_connect('jeff', 'zoneconveer_2000', '10.114.57.135/XE', "'AL32UTF8'");
    if (!$conn) {
        header("HTTP/1.0 503");
        $e = oci_error();
        echo json_encode(array("oracle_connect_error" => $e['message']));
        die("Database unavailable");
        exit;
    }
    
    $link = "http://converzone.htl-perg.ac.at/profile_images/" . $_FILES["uploaded_file"]["name"];
    $sql = oci_parse($conn, "UPDATE USERS SET PROFILE_PICTURE_URL = :link WHERE USERID = 1");
    
    //ci_bind_by_name($sql, ':id', $id);
    oci_bind_by_name($sql, ':link', $link);
    
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
    
    //Close connection to database
    oci_close($conn);
    oci_free_statement($sql);

    
?>
