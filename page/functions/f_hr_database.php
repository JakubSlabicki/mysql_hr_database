<?php
if(!isset($_SESSION)) 
{ 
	session_start(); 
} 

######################################################################################################################################################
#FUNCTION 	f_hr_database_show_table_data()
#function argument: data array to be shown in table
#function does: shows table with data
#function returns: nth
function f_hr_database_select($arg_select_name, $arg_sel_select, $arg_sel_db, $arg_sel_where){	

		#$select_values = f_hr_database_return_query(arg_select: 'id, position_name',arg_from: 'db_position', arg_where:'1', arg_fetch_type: MYSQLI_NUM);
		$select_values = f_hr_database_return_query(arg_select: $arg_sel_select,arg_from: $arg_sel_db, arg_where:$arg_sel_where, arg_fetch_type: MYSQLI_NUM);
		echo '<select name="'.$arg_select_name.'" id="'.$arg_select_name.'">';
		foreach ($select_values as $arr){
		  echo '<option value="'.$arr[0].'">'.$arr[1].'</option>';
		}
		echo '</select>';
}

######################################################################################################################################################
#FUNCTION 	f_hr_database_show_table_data()
#function argument: data array to be shown in table
#function does: shows table with data
#function returns: nth
function f_hr_database_enum_select($arg_select_name, $arg_enum_db, $arg_enum_column, $arg_enum_array = []){	

		if (empty($arg_enum_array)){
			$arg_enum_array = f_hr_database_procedure_output($arg_query_procedure = "P_get_column_enum_values_as_string", $arg_arguments_array = [$arg_enum_db, $arg_enum_column]);
			$arg_enum_array = explode(",", $arg_enum_array[0][0]);
		}
		echo '<select name="'.$arg_select_name.'" id="'.$arg_select_name.'">';
		foreach ($arg_enum_array as $key=>$arr){
		  echo '<option value="'.$key.'">'.$arr.'</option>';
		}
		echo '</select>';
}


######################################################################################################################################################
#FUNCTION 	f_hr_database_show_all_users()
#function argument: table name and all needed names for query
#function does: does select html
#function returns: nth
function f_hr_database_show_all_users($arg_list_sql_qyery = []){	

	if (empty($arg_list_sql_qyery)){
	$arg_list_sql_qyery = [
			['*','db_users', 	'1'],
			['*','v_user', 		'1'],
			['*','v_user_course_assign', 	'1'],
			['*','v_user_resource_assign', 	'1'], 
			['*','v_user_skill_assign', 	'1']];
	}
	if (is_array($arg_list_sql_qyery[0]))
	{
		foreach ($arg_list_sql_qyery as $arr)
		{
			f_hr_database_show_table_data(f_hr_database_return_query(arg_select: $arr[0], arg_from: $arr[1], arg_where: $arr[2], arg_fetch_type: MYSQLI_ASSOC));
		}
	}
	else
	{
		f_hr_database_show_table_data(f_hr_database_return_query(arg_select: $arg_list_sql_qyery[0], arg_from: $arg_list_sql_qyery[1], arg_where: $arg_list_sql_qyery[2], arg_fetch_type: MYSQLI_ASSOC));
	}
				
}
######################################################################################################################################################
#FUNCTION 	f_hr_database_show_table_data()
#function argument: data array to be shown in table
#function does: shows table with data
#function returns: nth
function f_hr_database_show_table_data($arg_table_array = []){	
	if (!empty($arg_table_array)){
		$column_no = count($arg_table_array[0]);
		$column_keys = array_keys($arg_table_array[0]);
		echo '<div>';
			echo '<table >';
				echo '<colgroup>';
				for ($i = 1; $i <= $column_no; $i++) {
					echo '<col style="width:'.floor(100/$column_no).'%">';
				}
					echo '</colgroup>';
					echo '  <tr>';
						foreach ($column_keys as $column) 
						{
							echo '<th>'.ucfirst(str_replace('_',' ',$column)).'</th>';
						}
						 echo '</tr>';
					foreach ($arg_table_array as $row) 
					{	
						echo '<tr>';
						foreach ($row as $cell) 
						{
							echo '<td style="text-align: center;">' . $cell . '</td>';
						}
						echo '</tr>'; 
					}
			echo '</table>';				
		echo '</div> ';	
		echo '<br/>';
	}
}
######################################################################################################################################################
#FUNCTION 	f_hr_database_return_query()
#function argument: mysql query select, from, where values
#function does: creates mysql query
#function returns: sql output array 
function f_hr_database_return_query($arg_select = "*", $arg_from = "v_user", $arg_where = "1", $arg_fetch_type = MYSQLI_ASSOC){	
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
			
			$arg_query_select = $polaczenie->real_escape_string($arg_select);
			$arg_query_from = $polaczenie->real_escape_string($arg_from);			
			$arg_query_where = $polaczenie->real_escape_string($arg_where);
			if($resultat = $polaczenie->query("SELECT {$arg_query_select} FROM {$arg_query_from} WHERE {$arg_query_where}"))
			{	
				if($resultat->num_rows >= 1)
				{
					while($row = mysqli_fetch_array($resultat, $arg_fetch_type))
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
			if ($resultat)
			{
				$resultat->free(); // question 1: why risk it?
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