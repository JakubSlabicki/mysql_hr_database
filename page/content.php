<!-- zawartość srodka strony -->
<?php
	
	require_once('page/functions/f_hr_database.php');
	require_once('page/functions/f_hr_database_procedure.php');
	
	
	
	if (isset($_GET['page']))  
		$page = $_GET["page"]; 
    else 
        $page = "home"; 
		switch($page){
		case "hr_database":
			include('page/content/hr_database.php');
			break;			
		default:
			include('page/content/home.php');
			break;
		}
	

?>