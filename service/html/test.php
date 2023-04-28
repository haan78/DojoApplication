<?php 

$mysqli = new mysqli("mysql","dojosensei", "UUmFxv@2C67&27Ckf_3Gv", "dojo");

$query = $mysqli->prepare("SET @a = 1;");
if (!$query) {
    echo mysqli_error($mysqli);
    exit();
}
if (!$query->execute()) {
    echo mysqli_stmt_error($query);
} else {
    echo "success";
}
$query->store_result();
$result = $query->get_result();
var_dump($result);
echo (mysqli_num_rows($result));

mysqli_free_result($result);
mysqli_stmt_close($query);
mysqli_close($mysqli);