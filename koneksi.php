
<?php
$servername = "localhost"; // Alamat server database
$username = "root";        // Username database
$password = "";            // Password database
$dbname = "pet_shop";      // Nama database

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}
?>
