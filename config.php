<?php
if ($_SERVER['QUERY_STRING'] == "update") {
$new_config = $_POST['config'];
file_put_contents('config.cl', $new_config);
}
$config = file_get_contents('config.cl');
?>

<form action="config.php?update" id="update" method="post">
<textarea  rows="30" cols="75" name="config" form="update"><?php echo $config ?></textarea>
<input type="submit">
</form>
<?php