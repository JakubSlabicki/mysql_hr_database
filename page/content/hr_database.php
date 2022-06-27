<style>
body {font-family: Arial;}

/* Style the tab */
.tab {
  overflow: hidden;
  border: 1px solid #ccc;
  background-color: #f1f1f1;
}

/* Style the buttons inside the tab */
.tab button {
  background-color: inherit;
  float: left;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
  font-size: 17px;
}

/* Change background color of buttons on hover */
.tab button:hover {
  background-color: #ddd;
}

/* Create an active/current tablink class */
.tab button.active {
  background-color: #ccc;
}

/* Style the tab content */
.tabcontent {
  display: none;
  padding: 6px 12px;
  border-top: none;
}
</style>
<script>
function openTab(evt, TabID) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace("active", "");
  }
  document.getElementById(TabID).style.display = "block";
  evt.currentTarget.className += " active";
}

</script>
<?php
$_SESSION['page'] = ' /majgit/index.php?page=hr_database';
if (isset($_SESSION['sql_out'])){
	echo $_SESSION['sql_out'];
	unset($_SESSION['sql_out']);
}
$array_tab_data = [
	['Users',			'User data',					['*','v_user', '1'],					'Add new user',				'P_add_new_user'],
	['Courses',			'Course assign table',			['*','v_user_course_assign', 	'1'], 	'Change cource status',		'P_change_user_course_assign'],
	['Resources',		'Resource assign table',		['*','v_user_resource_assign', 	'1'],	'Change resource status',	'P_change_user_resource_assign'],
	['Skills',			'Skill assign table',			['*','v_user_skill_assign', 	'1'],	'Change skill status',		'P_change_user_skill_assign'],
	['Skills',			'Skill assign table',			['*','v_user_skill_assign', 	'1']],
	['Earnings',		'Earnings table',				['*','v_user_earnings ', 	'1']],
	['Earnings history','Earnings information table',	['*','v_user_earnings_changes', '1'],	'Change users earings',		'P_change_user_earnings'],
	['Earnings oversight',	'Earnings oversight table',	['*','db_earnings_oversight', '1'],		'Change users earings',		'P_change_user_earnings']
	];
	
$array_query_data = array(
    "P_add_new_user" => 				[["first_name","text", "First name"],["second_name","text", "Second name"],["position_id","select", "Position"],["earnings","number", "Earings"]],
    "P_change_user_course_assign" => 	[["user_id","select", "User"],["course_id","select", "Course"],["change_course_status","enum", "New status"]],
    "P_change_user_resource_assign" => 	[["user_id","select", "User"],["resource_id","select", "Resoure"],["change_resource_status","enum", "New status"]],
    "P_change_user_skill_assign" => 	[["user_id","select", "User"],["skill_id","select", "Skill"],["change_skill_status","enum", "New status"]],
    "P_change_user_earnings" => 		[["user_id","select", "User"],["change_type","enum", "Change type"],["change_value","number", "Value"]]
);

$array_select_data = array(
    "user_id" => 		["id, login","db_users", "1"],
    "position_id" => 	["id, position_name","db_position", "1"],
    "course_id" => 		["id, name","db_course_matrix", "1"],
    "resource_id" => 	["id, name","db_resources", "1"],
    "skill_id" => 		["id, name","db_skill_matrix", "1"]
);
$earnings_change_type_array = [
	1 =>'The amount of the increase',
	2 =>'The amount of the pay cut ',
	3 =>'Percentage of the increase',
	4 =>'Percentage of the pay cut '];
$array_enum_data = array(
    "change_course_status" => 		['db_user_course_assign','status'],
    "change_resource_status" => 	['db_user_resource_assign','status'],
    "change_skill_status" => 		['db_user_skill_assign','status'],
    "change_type" => 				['db_user_skill_assign','status', $earnings_change_type_array]
);

	echo '<div class="tab">';
		foreach($array_tab_data as $index=>$arr) {
			echo '<button class="tablinks" type="button" onclick="openTab(event, '.$index.')"  ';
			if ($index == 0)
				echo 'id="defaultOpen" ';
			echo '>'.$arr[0].'</button>';
		}
	echo '</div>';
	foreach($array_tab_data as $index=>$arr) {
		echo '<div id="'.$index.'" class="tabcontent">';

			if (is_array($arr[2])) 	{
				echo '<div style="width:45%; padding: 2%;float:left;">';
					echo '<h3>'.$arr[1].':</h3><br/>';
					f_hr_database_show_all_users($arr[2]);
				echo '</div>';
				if(isset($arr[3])){
					echo '<div style="width:45%; padding: 2%; float:right;border-left: 1px solid #ccc;">';
					
						echo '<h3>'.$arr[3].':</h3><br/>';
						echo '<form id="form_procedure" action="page/functions/f_hr_database_procedure.php" method="post" enctype="multipart/form-data" >';
							foreach ($array_query_data[$arr[4]] as $query_data)	{
								echo'<label for="'.$query_data[0].'">'.$query_data[2].':</label><br/>';
								if ($query_data[1] == 'select'){
									$select_arr = $array_select_data[$query_data[0]];
									f_hr_database_select($query_data[0],$select_arr[0],$select_arr[1],$select_arr[2]);
									echo '<br/><br/>';
								}
								elseif ($query_data[1] == 'enum'){
									$select_arr = $array_enum_data[$query_data[0]];
									if (isset($select_arr[2]))
										f_hr_database_enum_select($query_data[0],$select_arr[0],$select_arr[1],$select_arr[2]);
									else
										f_hr_database_enum_select($query_data[0],$select_arr[0],$select_arr[1]);
									echo '<br/><br/>';
								}
								else
									echo'<input type="'.$query_data[1].'" id="'.$query_data[0].'" name="'.$query_data[0].'"><br/><br/>';
							}
							
							echo'<input type="hidden" id="procedure" name="procedure" value="'.$arr[4].'">';
							echo'<input type="submit" id="Submit" name="submit" value="Submit">';
						echo '</form>';
					echo '</div>';
				}
			}
		echo '</div>';
	}	
		
?>
