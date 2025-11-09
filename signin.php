<?php
// Database connection
$servername = "localhost";
$username = "root";        // MySQL username
$password = "";            // MySQL password
$dbname = "kky_meatshop";  // Database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Get form values
$email = $_POST['email'];
$password = $_POST['password'];

// Check if user exists
$sql = "SELECT * FROM users WHERE email = '$email'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  $row = $result->fetch_assoc();

  // Verify hashed password
  if (password_verify($password, $row['password'])) {
    echo "success";
  } else {
    echo "error: Invalid password";
  }
} else {
  echo "error: No user found";
}

$conn->close();
?>
