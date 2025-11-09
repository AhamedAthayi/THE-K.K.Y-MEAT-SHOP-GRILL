<?php
// Database connection
$servername = "localhost"; // or 127.0.0.1
$username = "root";        // your MySQL username
$password = "";            // your MySQL password
$dbname = "kky_meatshop";  // your database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Receive form data
$fullName = $_POST['fullName'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$address = $_POST['address'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

// Insert into database
$sql = "INSERT INTO users (fullName, email, phone, address, password)
        VALUES ('$fullName', '$email', '$phone', '$address', '$password')";

if ($conn->query($sql) === TRUE) {
  echo "success";
} else {
  echo "error: " . $conn->error;
}

$conn->close();
?>
