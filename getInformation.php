
<?php

$id = $_POST["id"];

    
if(empty($id)){
header("HTTP/1.0 510");
exit;
}

// Connect to Database
$conn = oci_connect('jeff', 'zoneconveer_2000', '10.114.57.135/XE', 'AL32UTF8');
if (!$conn) {
header("HTTP/1.0 503");
$e = oci_error();
echo json_encode(array("oracle_connect_error" => $e['message']));
die("Database unavailable");
exit;
}

$sql = oci_parse($conn, "SELECT LANGUAGE, PROFICIENCY FROM LANGUAGEPROFICIENCIES WHERE USERID = $id");

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
echo json_encode(array("language_error" => "User has no languages saved"));
exit;
}

echo json_encode($store_rows);

//Close connection to database
oci_close($conn);
oci_free_statement($sql);

?>
