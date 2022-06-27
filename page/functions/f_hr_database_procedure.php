<?php
if(!isset($_SESSION)) 
{ 
	session_start(); 
} 
if(isset($_POST['submit'])) #spare_parts_take
{
	$procedure_arguments = [];
	foreach($_POST as $key=>$val){
		if ($key != 'procedure' AND $key != 'submit')
			array_push($procedure_arguments,$val);
	}
	f_hr_database_procedure_query($_POST['procedure'], $procedure_arguments);
}
######################################################################################################################################################
#FUNCTION 	f_hr_database_return_query()
#function argument: mysql query select, from, where values
#function does: creates mysql query
#function returns: sql output array 
function f_hr_database_procedure_query($arg_query_procedure = "*", $arg_arguments_array = []){	
	$return_array = [];
	mysqli_report(MYSQLI_REPORT_STRICT);
	try
	{
		$polaczenie = @new mysqli("localhost","hr_administrator","admin","hr_database");
		if ($polaczenie->connect_errno!=0)
		{
			throw new Exception(mysqli_connect_errno());
		}
		else
		{
			$resultat = NULL;
			
			$arg_query_procedure = $polaczenie->real_escape_string($arg_query_procedure);
			for ($i = 0; $i <= (count($arg_arguments_array)-1); $i++) {
				$arg_arguments_array[$i] = $polaczenie->real_escape_string($arg_arguments_array[$i]);
			}
			$arg_argument = '\'' . implode(' \', \'', $arg_arguments_array) . '\'';
			$sql_query ="CALL {$arg_query_procedure} ({$arg_argument}, @out_error ); ";
			if($resultat = $polaczenie->query($sql_query))
			{					
				$polaczenie -> close();
				$_SESSION['sql_out'] = 'Data has been changed.';
			}
			header('Location: '. $_SESSION['page']);
		}
	}
	catch(Exception $e)
	{
		echo '<span style="color:red;"> Błąd serwera! za niedogodności i prosimy o rejestracje w innymm terminie! </span>';
		echo '<br/>I Informacja developerska: '.$e;			
	}
	return $return_array;
}
######################################################################################################################################################
#FUNCTION 	f_hr_database_return_query()
#function argument: mysql query select, from, where values
#function does: creates mysql query
#function returns: sql output array 
function f_hr_database_procedure_output($arg_query_procedure = "*", $arg_arguments_array = []){	
	$return_array = [];
	mysqli_report(MYSQLI_REPORT_STRICT);
	try
	{
		$polaczenie = @new mysqli("localhost","hr_administrator","admin","hr_database");
		if ($polaczenie->connect_errno!=0)
		{
			throw new Exception(mysqli_connect_errno());
		}
		else
		{
			$resultat = NULL;
			
			$arg_query_procedure = $polaczenie->real_escape_string($arg_query_procedure);
			for ($i = 0; $i <= (count($arg_arguments_array)-1); $i++) {
				$arg_arguments_array[$i] = $polaczenie->real_escape_string($arg_arguments_array[$i]);
			}
			$arg_argument = '\'' . implode(' \', \'', $arg_arguments_array) . '\'';
			$sql_query ="CALL {$arg_query_procedure} ({$arg_argument}); ";
			if($resultat = $polaczenie->query($sql_query))
			{	
				if($resultat->num_rows >= 1)
				{
					while($row = mysqli_fetch_array($resultat, MYSQLI_NUM))
					{
						array_push($return_array, $row);
					}	
				}
				else
				{
					echo 'No data in database. Create new query.';
				}		
				$polaczenie -> close();
			}
		}
	}
	catch(Exception $e)
	{
		echo '<span style="color:red;"> Błąd serwera! za niedogodności i prosimy o rejestracje w innymm terminie! </span>';
		echo '<br/>I Informacja developerska: '.$e;			
	}
	return $return_array;
}
?>