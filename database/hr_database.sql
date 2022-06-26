SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `cmms`
--
CREATE DATABASE IF NOT EXISTS `hr_database` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `hr_database`;

DELIMITER $$


CREATE DEFINER=`root`@`localhost` PROCEDURE `P_change_user_earnings`(IN `IN_user_id` INT, IN `IN_change_type` INT, IN `IN_change_value` INT,  OUT out_error INT)
-- Procedure: P_change_user_earnings
-- Changes users earings
-- OUT ERRORS:
-- NULL 	- No errors, change done 
-- No: 1	- User id does not EXISTS
-- No: 2	- User earings does not changed because of wrong input chanhe value
BEGIN
	-- Declare variables
    DECLARE employee_new_earnings int;
    DECLARE employee_earnings int;
	DECLARE employee_id int;
	
		-- Check if user exists
	SELECT id INTO employee_id FROM db_users WHERE id = IN_user_id;
	IF employee_id THEN
	
		-- Change user's earnings depending on chanhe type
		  -- IN_change_type:
		  -- 		1- The amount of the increase
		  -- 		2- The amount of the pay cut 
		  -- 		3- Percentage of the increase
		  -- 		4- Percentage of the pay cut 
		SELECT earnings INTO employee_earnings FROM db_users WHERE id = IN_user_id;
		CASE IN_change_type
			WHEN '1' THEN
			   SET employee_new_earnings = employee_earnings + IN_change_value;
			   SET out_error = NULL;
			WHEN '2' THEN
			   SET employee_new_earnings = employee_earnings - IN_change_value;
			   SET out_error = NULL;
			WHEN '3' THEN
			   SET employee_new_earnings = employee_earnings + IN_change_value * employee_earnings / 100;
			   SET out_error = NULL;
			WHEN '4' THEN
			   SET employee_new_earnings = employee_earnings - IN_change_value * employee_earnings / 100;
			   SET out_error = NULL;
			ELSE
			   SET employee_new_earnings = employee_earnings;
			   SET out_error = 2;
		END CASE;
		IF out_error IS NULL THEN
			UPDATE `db_users` SET `earnings`= employee_new_earnings WHERE id = IN_user_id;
		END IF;
	ELSE
		-- Set error as user does not exists
		SET out_error = 1;
	END IF;
END$$


CREATE DEFINER=`root`@`localhost` PROCEDURE `P_add_new_user`(IN `IN_first_name` VARCHAR(100), IN `IN_second_name` VARCHAR(100), IN `IN_position_id` INT,IN `IN_earnings` INT,  OUT out_error INT)
-- Procedure: P_add_new_user
-- Adds new user to database
-- OUT ERRORS:
-- NULL 	- No errors, change done 
-- No: 1	- User position does not EXISTS
BEGIN
	-- Declare variables
    DECLARE employee_position int;
	
	-- Check if position exists
	SELECT id INTO employee_position FROM db_position WHERE id = IN_position_id;
	IF employee_position THEN
	
		-- Creates specified login and email adress
		SET @login = LOWER(CONCAT(SUBSTRING(IN_second_name,1,5),SUBSTRING(IN_first_name,1,1))); 
		SET @email = LOWER(CONCAT(@login, '@test.com')); 
		
		-- Insert new user data
		INSERT INTO `db_users` 
			(`id`, `login`, `password`, `first_name`, `second_name`, `email`, `position`, `earnings`, `status`) 
		VALUES 
			(NULL,  @login, NULL, IN_first_name, IN_second_name, @email, IN_position_id, IN_earnings, 'ACTIVE');
		SET out_error = NULL;
	ELSE
		-- Set error as user does not exists
		SET out_error = 1;
	END IF;
END$$


CREATE DEFINER=root@localhost PROCEDURE P_change_user_course_assign(IN IN_user_id INT, IN IN_course_id INT, IN IN_change_value enum('DONE', 'IN PROGRES', 'NOT DONE'),  OUT out_error INT)
-- Procedure: P_change_user_course_assign
-- Changes user's coursed assign 
-- OUT ERRORS:
-- NULL 	- No errors, change done 
-- No: 1	- User id does not EXISTS
-- No: 2	- Course statuses ARE THE SAME or does not EXIST
BEGIN
	-- Declare variables
    DECLARE status_info enum('DONE', 'IN PROGRES', 'NOT DONE');
	DECLARE employee_id int;
	
	-- Check if user exists
	SELECT id INTO employee_id FROM db_users WHERE id = IN_user_id;
	IF employee_id THEN
	
		-- Check if new status is different
		SELECT status INTO status_info FROM db_user_course_assign WHERE user_id = IN_user_id AND course_id = IN_course_id;
		IF status_info != IN_change_value THEN
		
			-- Update changes
			UPDATE db_user_course_assign SET status= IN_change_value WHERE user_id = IN_user_id  AND course_id = IN_course_id;
			SET out_error = NULL;
			
		ELSE
			-- Set etror as statuses are the same or does not exists
			SET out_error = 2;
			
		END IF; 
	ELSE
		-- Set error as user does not exists
		SET out_error = 1;
	END IF;
END$$


CREATE DEFINER=root@localhost PROCEDURE P_change_user_resource_assign(IN IN_user_id INT, IN IN_resource_id INT, IN IN_change_value enum('DISPENSED', 'PENDING', 'NOT ACCEPTED'),  OUT out_error INT)
-- Procedure: P_change_user_resource_assign
-- Changes user's resource assign 
-- OUT ERRORS:
-- NULL 	- No errors, change done 
-- No: 1	- User id does not EXISTS
-- No: 2	- Course statuses ARE THE SAME or does not EXIST
BEGIN
	-- Declare variables
    DECLARE employee_id int;
    DECLARE status_info enum('DISPENSED', 'PENDING', 'NOT ACCEPTED');
	SET @creation_date = current_timestamp();
	
	-- Check if user exists
	SELECT id INTO employee_id FROM db_users WHERE id = IN_user_id;
	IF employee_id THEN
	
		-- Check if new status is different
		SELECT status INTO status_info FROM db_user_resource_assign WHERE user_id = IN_user_id AND resource_id  = IN_resource_id;
		IF status_info != IN_change_value THEN
		
			-- Update changes
			UPDATE db_user_resource_assign SET status= IN_change_value WHERE user_id = IN_user_id  AND resource_id = IN_resource_id;
			SET out_error = NULL;
			
		ELSE
			-- Set error as statuses are the same or does not exists
			SET out_error = 2;
			
		END IF; 
	ELSE
		-- Set error as user does not exists
		SET out_error = 1;
	END IF;
END$$



CREATE DEFINER=root@localhost PROCEDURE P_change_user_skill_assign(IN IN_user_id INT, IN IN_skill_id INT, IN IN_change_value enum('HAVE', 'IN PROGRES', 'NOT HAVE'),  OUT out_error INT)
-- Procedure: db_user_resource_assign
-- Changes user's skill assign 
-- OUT ERRORS:
-- NULL 	- No errors, change done 
-- No: 1	- User id does not EXISTS
-- No: 2	- Course statuses ARE THE SAME or does not EXIST
BEGIN
	-- Declare variables
    DECLARE employee_id int;
    DECLARE status_info enum('HAVE', 'IN PROGRES', 'NOT HAVE');
	SET @creation_date = current_timestamp();
	
	-- Check if user exists
	SELECT id INTO employee_id FROM db_users WHERE id = IN_user_id;
	IF employee_id THEN
	
		-- Check if new status is different
		SELECT status INTO status_info FROM db_user_skill_assign WHERE user_id = IN_user_id AND skill_id = IN_skill_id;
		IF status_info != IN_change_value THEN
		
			-- Update changes
			UPDATE db_user_skill_assign SET status= IN_change_value WHERE user_id = IN_user_id  AND skill_id = IN_skill_id;
			SET out_error = NULL;
			
		ELSE
			-- Set error as statuses are the same or does not exists
			SET out_error = 2;
			
		END IF; 
	ELSE
		-- Set error as user does not exists
		SET out_error = 1;
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `P_get_column_enum_values_as_string`(IN `IN_table` VARCHAR(100), IN `IN_column` VARCHAR(100))
-- Procedure: P_get_column_enum_values_as_string
-- Returns enum values from selected column of db as string
BEGIN
	DECLARE string_enum VARCHAR(100);
		SELECT SUBSTRING(COLUMN_TYPE,5) INTO string_enum FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='hr_database' AND TABLE_NAME= IN_table AND COLUMN_NAME= IN_column;
    SET string_enum = REPLACE(REPLACE(REPLACE(string_enum,'\'',''),')',''),'(','');
	SELECT string_enum;
END$$
DELIMITER ;

DELIMITER ;

CREATE TABLE `db_users` (
  `id` int(11) NOT NULL,
  `login` varchar(50) CHARACTER SET utf8 COLLATE utf8_polish_ci NOT NULL,
  `password` varchar(100) DEFAULT NULL,
  `first_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_polish_ci NOT NULL,
  `second_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_polish_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_polish_ci NOT NULL,
  `position` int(11) NOT NULL,
  `earnings` int(11) NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `db_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_users_id` (`id`),
  ADD UNIQUE KEY `UK_db_users_login` (`login`),
  ADD UNIQUE KEY `UK_db_users_email` (`email`);
  


CREATE TABLE `db_position` (
  `id` int(11) NOT NULL,
  `position_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `earnings_group` int(11) NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `db_position`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_position_id` (`id`);

CREATE TABLE `db_earnings_group` (
  `id` int(11) NOT NULL,
  `minimal_earnings` int(11) NOT NULL,
  `maximal_earnings` int(11) NOT NULL,
  `currency` varchar(20) CHARACTER SET utf8 NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


ALTER TABLE `db_earnings_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_earnings_group_id` (`id`);
  
  
CREATE TABLE `db_resources` (
  `id` int(11) NOT NULL,
  `name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `serial` varchar(20) CHARACTER SET utf8 NOT NULL,
  `purchase_date` datetime DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


ALTER TABLE `db_resources`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_resources_id` (`id`);
  

CREATE TABLE `db_user_resource_assign` (
  `user_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `handover_date` datetime DEFAULT NULL,
  `status` enum('DISPENSED','PENDING','NOT ACCEPTED') NOT NULL DEFAULT 'DISPENSED'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;



CREATE TABLE `db_position_resource_assign` (
  `position_id` int(11) NOT NULL,
  `resource_id` int(11) NOT NULL,
  `status` enum('REQUIRED','NICE TO HAVE','NOT REQUIRED') NOT NULL DEFAULT 'REQUIRED'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `db_user_holiday` (
  `user_id` int(11) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL,
  `consideration_date` datetime DEFAULT NULL,
  `status` enum('ACCEPTED','PENDING','NOT ACCEPTED') NOT NULL DEFAULT 'PENDING'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `db_skill_matrix` (
  `id` int(11) NOT NULL,
  `name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `type` enum('HARD SKILLS','SOFT SKILLS') NOT NULL DEFAULT 'HARD SKILLS',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


ALTER TABLE `db_skill_matrix`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_skill_matrix_id` (`id`);


CREATE TABLE `db_position_skill_assign` (
  `position_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `status` enum('REQUIRED','NICE TO HAVE','NOT REQUIRED') NOT NULL DEFAULT 'REQUIRED'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;




CREATE TABLE `db_user_skill_assign` (
  `user_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `status` enum('HAVE','IN PROGRES','NOT HAVE') NOT NULL DEFAULT 'NOT HAVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `db_course_matrix` (
  `id` int(11) NOT NULL,
  `name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `type` int(11) NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


ALTER TABLE `db_course_matrix`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_course_matrix_id` (`id`);

CREATE TABLE `db_course_type` (
  `id` int(11) NOT NULL,
  `name` varchar(20) CHARACTER SET utf8 NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


ALTER TABLE `db_course_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_course_type_id` (`id`);

CREATE TABLE `db_position_course_assign` (
  `position_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` enum('REQUIRED','NICE TO HAVE','NOT REQUIRED') NOT NULL DEFAULT 'REQUIRED'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `db_user_course_assign` (
  `user_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` enum('DONE','IN PROGRES','NOT DONE') NOT NULL DEFAULT 'NOT DONE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `db_course_skill` (
  `course_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `company` varchar(20) CHARACTER SET utf8 NOT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `db_earnings_changes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `information` longtext CHARACTER SET utf8 NOT NULL,
  `creation_date` datetime DEFAULT NULL
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `db_earnings_changes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_db_earnings_changes_id` (`id`);

CREATE TABLE `db_earnings_oversight` (
  `user_id` int(11) NOT NULL,
  `information` longtext CHARACTER SET utf8 NOT NULL,
  `status` enum('MISTAKE','WARNING','FUTURE PROMOTION') NOT NULL DEFAULT 'WARNING'
) ENGINE=InnoDB AVG_ROW_LENGTH=5461 DEFAULT CHARSET=utf8mb4;

ALTER TABLE `db_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	

ALTER TABLE `db_position`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	
  
ALTER TABLE `db_earnings_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	

ALTER TABLE `db_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	

ALTER TABLE `db_skill_matrix`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	
  
ALTER TABLE `db_course_matrix`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	
  
ALTER TABLE `db_course_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	
  
ALTER TABLE `db_earnings_changes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;	

INSERT INTO `db_course_type` (`id`, `name`, `status`) VALUES (NULL, 'Office IT', 'ACTIVE');
INSERT INTO `db_course_type` (`id`, `name`, `status`) VALUES (NULL, 'Software', 'ACTIVE');
INSERT INTO `db_course_type` (`id`, `name`, `status`) VALUES (NULL, 'Communication', 'ACTIVE');
INSERT INTO `db_course_type` (`id`, `name`, `status`) VALUES (NULL, 'Psychology', 'ACTIVE');

  
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'MS Office Excel', '1', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'MS Office Word', '1', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Python for Beginners', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Python for Juniors ', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Python for Seniors ', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'C++ for Beginners', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'C++ for Juniors ', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'C++ for Seniors ', '2', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Team Communication', '3', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Communication in Business', '3', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Communication in Management', '3', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Communication in Administration ', '3', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Psychology in Business', '4', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Psychology in Management', '4', 'ACTIVE');
INSERT INTO `db_course_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Psychology in Administration ', '4', 'ACTIVE');

INSERT INTO `db_skill_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'MS Office', 'HARD SKILLS', 'ACTIVE');
INSERT INTO `db_skill_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Python', 'HARD SKILLS', 'ACTIVE');
INSERT INTO `db_skill_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'C++', 'HARD SKILLS', 'ACTIVE');
INSERT INTO `db_skill_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Communication', 'SOFT SKILLS', 'ACTIVE');
INSERT INTO `db_skill_matrix` (`id`, `name`, `type`, `status`) VALUES (NULL, 'Psychology', 'SOFT SKILLS', 'ACTIVE');

INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('1', '1', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('2', '1', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('3', '2', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('4', '2', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('9', '3', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('10', '3', 'Microsoft', 'ACTIVE');
INSERT INTO `db_course_skill` (`course_id`, `skill_id`, `company`, `status`) VALUES ('13', '4', 'Microsoft', 'ACTIVE');

INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '800', '1200', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '1600', '2400', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '2400', '3600', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '3200', '4800', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '4000', '6000', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '4800', '7200', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '5600', '8400', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '6400', '9600', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '7200', '10800', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '8000', '12000', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '8800', '13200', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '9600', '14400', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '10400', '15600', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '11200', '16800', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '12000', '18000', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '12800', '19200', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '13600', '20400', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '14400', '21600', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '15200', '22800', 'USD', 'ACTIVE');
INSERT INTO `db_earnings_group` (`id`, `minimal_earnings`, `maximal_earnings`, `currency`, `status`) VALUES (NULL, '16000', '24000', 'USD', 'ACTIVE');

INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Junior Python Developer', '2', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Python Developer', '3', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Senior Python Developer', '4', 'ACTIVE');

INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Junior C++ Developer', '2', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'C++ Developer', '3', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Senior C++ Developer', '4', 'ACTIVE');

INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Junior Project Manager', '4', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Project Manager', '5', 'ACTIVE');
INSERT INTO `db_position` (`id`, `position_name`, `earnings_group`, `status`) VALUES (NULL, 'Senior Project Manager', '6', 'ACTIVE');


INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('1', '1', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('1', '2', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('1', '3', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('1', '4', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('1', '9', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('4', '1', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('4', '2', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('4', '6', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('4', '7', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('4', '9', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '10', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '11', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '12', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '13', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '14', 'REQUIRED');
INSERT INTO `db_position_course_assign` (`position_id`, `course_id`, `status`) VALUES ('8', '15', 'REQUIRED');

INSERT INTO `db_resources` (`id`, `name`, `serial`, `purchase_date`, `status`) VALUES (NULL, 'Laptop Google', 'Google Pixelbook Go', '2022-05-23 12:33:27.000000', 'ACTIVE');
INSERT INTO `db_resources` (`id`, `name`, `serial`, `purchase_date`, `status`) VALUES (NULL, 'Laptop MacBook', 'MacBook Pro 14-inch', '2022-05-23 12:33:27.000000', 'ACTIVE');

INSERT INTO `db_position_resource_assign` (`position_id`, `resource_id`, `status`) VALUES ('1', '1', 'REQUIRED');
INSERT INTO `db_position_resource_assign` (`position_id`, `resource_id`, `status`) VALUES ('4', '1', 'REQUIRED');
INSERT INTO `db_position_resource_assign` (`position_id`, `resource_id`, `status`) VALUES ('8', '2', 'REQUIRED');

INSERT INTO `db_position_skill_assign` (`position_id`, `skill_id`, `status`) VALUES ('1', '2', 'REQUIRED');
INSERT INTO `db_position_skill_assign` (`position_id`, `skill_id`, `status`) VALUES ('4', '3', 'REQUIRED');
INSERT INTO `db_position_skill_assign` (`position_id`, `skill_id`, `status`) VALUES ('8', '4', 'REQUIRED');


DELIMITER $$
CREATE TRIGGER `T_db_users_db_position_course_assign_AFTER_INSERT` AFTER INSERT ON `db_users`
 FOR EACH ROW BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE fetch_value INT;
	DECLARE cursor_row CURSOR FOR SELECT `course_id` FROM `db_position_course_assign` WHERE `position_id` = NEW.position;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cursor_row;
        insert_loop: LOOP
            FETCH cursor_row INTO fetch_value;
            IF done THEN
                LEAVE insert_loop;
            END IF;
			INSERT INTO `db_user_course_assign`(`user_id`, `course_id`, `status`) VALUES (NEW.id, fetch_value, 'NOT DONE');
        END LOOP;
    CLOSE cursor_row;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T_db_users_db_user_resource_assign_AFTER_INSERT` AFTER INSERT ON `db_users`
 FOR EACH ROW BEGIN
	
	DECLARE done INT DEFAULT FALSE;
	DECLARE fetch_value INT;
	DECLARE cursor_row CURSOR FOR 	SELECT `resource_id` FROM `db_position_resource_assign` WHERE position_id = NEW.position;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	SET @creation_date = current_timestamp();
	OPEN cursor_row;
        insert_loop: LOOP
            FETCH cursor_row INTO fetch_value;
            IF done THEN
                LEAVE insert_loop;
            END IF;
			INSERT INTO `db_user_resource_assign`(`user_id`, `resource_id`, `handover_date`, `status`) VALUES (NEW.id, fetch_value,@creation_date,'PENDING');
        END LOOP;
    CLOSE cursor_row;
END

$$
DELIMITER ;
DELIMITER $$

CREATE TRIGGER `T_db_users_db_position_skill_assign_AFTER_INSERT` AFTER INSERT ON `db_users`
 FOR EACH ROW BEGIN
	
	DECLARE done INT DEFAULT FALSE;
	DECLARE fetch_value INT;
	DECLARE cursor_row CURSOR FOR 	SELECT `skill_id` FROM `db_position_skill_assign` WHERE position_id = NEW.position;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	SET @creation_date = current_timestamp();
	OPEN cursor_row;
        insert_loop: LOOP
            FETCH cursor_row INTO fetch_value;
            IF done THEN
                LEAVE insert_loop;
            END IF;
			INSERT INTO `db_user_skill_assign`(`user_id`, `skill_id`, `status`) VALUES (NEW.id, fetch_value,'NOT HAVE');
        END LOOP;
    CLOSE cursor_row;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T_db_users_db_earning_changes_AFTER_UPDATE` AFTER UPDATE ON `db_users`
 FOR EACH ROW BEGIN
  IF NEW.earnings!=OLD.earnings THEN
	SET @description = '';
	SET @information = '';
	SET @creation_date = current_timestamp();
    SELECT `earnings_group` INTO @earnings_group FROM `db_position` WHERE id = NEW.position;
    SELECT `minimal_earnings` INTO @minimal_earnings FROM `db_earnings_group` WHERE id = @earnings_group;
    SELECT `maximal_earnings` INTO @maximal_earnings FROM `db_earnings_group` WHERE id = @earnings_group;
	SET @promotion_border  = @maximal_earnings * 0.95;
	IF NEW.earnings > @minimal_earnings AND NEW.earnings <= @maximal_earnings THEN
		SET @description = CONCAT(@description,'New wages of employee: ', NEW.earnings,' (from ', OLD.earnings,'). All in group ranges.\n');
	ELSE
		SET @description = CONCAT(@description,'New wages of employee: ', NEW.earnings,' (from ', OLD.earnings,') , although from group affiliation, should be in the range (',@minimal_earnings,' to ',@maximal_earnings,'). Change group or earnings.\n');
	END IF;
	INSERT INTO `db_earnings_changes`(`id`,`user_id`, `information`, `creation_date`) VALUES (NULL, NEW.id, @description,@creation_date);
	
	--  INSERT INTO `db_earnings_oversight`

	IF NEW.earnings < @minimal_earnings  THEN
		SET @information = CONCAT(@information,'New wages of employee is too small: ', NEW.earnings,' (from ', OLD.earnings,'), although from group affiliation, should be in the range (',@minimal_earnings,' to ',@maximal_earnings,'). Change group or earnings.\n');
		IF (SELECT user_id FROM db_earnings_oversight WHERE `user_id` = NEW.id LIMIT 1) THEN
			UPDATE `db_earnings_oversight` SET `information`=@information,`status`='MISTAKE' WHERE `user_id` = NEW.id;
		ELSE
			INSERT INTO `db_earnings_oversight`(`user_id`, `information`, `status`) VALUES (NEW.id,@information,'MISTAKE');
		END IF;
	END IF;
	IF NEW.earnings >= @promotion_border  AND NEW.earnings <= @maximal_earnings THEN
		SET @information = CONCAT(@information,'New wages of employee is close to maximal earnigns: ', NEW.earnings,' (from ', OLD.earnings,'), although from group affiliation, should be in the range (',@minimal_earnings,' to ',@maximal_earnings,'). Change group or earnings.\n');
		IF (SELECT user_id FROM db_earnings_oversight WHERE `user_id` = NEW.id LIMIT 1) THEN
			UPDATE `db_earnings_oversight` SET `information`=@information,`status`='FUTURE PROMOTION' WHERE `user_id` = NEW.id;
		ELSE
			INSERT INTO `db_earnings_oversight`(`user_id`, `information`, `status`) VALUES (NEW.id,@information,'FUTURE PROMOTION');
		END IF;
	END IF;
	IF NEW.earnings >= @promotion_border  AND NEW.earnings >= @maximal_earnings THEN
		SET @information = CONCAT(@information,'New wages of employee is too big: ', NEW.earnings,' (from ', OLD.earnings,'), although from group affiliation, should be in the range (',@minimal_earnings,' to ',@maximal_earnings,'). Change group or earnings.\n');
		IF (SELECT user_id FROM db_earnings_oversight WHERE `user_id` = NEW.id LIMIT 1) THEN
			UPDATE `db_earnings_oversight` SET `information`=@information,`status`='WARNING' WHERE `user_id` = NEW.id;
		ELSE
			INSERT INTO `db_earnings_oversight`(`user_id`, `information`, `status`) VALUES (NEW.id,@information,'WARNING');
		END IF;
	END IF;
	IF NEW.earnings > @minimal_earnings AND NEW.earnings <= @maximal_earnings  AND  NEW.earnings <= @promotion_border THEN
		IF (SELECT user_id FROM db_earnings_oversight WHERE `user_id` = NEW.id LIMIT 1) THEN
			DELETE FROM `db_earnings_oversight` WHERE `user_id` = NEW.id;
		END IF;
	END IF;
	
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T_db_users_db_earning_changes_AFTER_INSERT` AFTER INSERT ON `db_users`
 FOR EACH ROW BEGIN
	SET @description = ' ';
    SELECT `earnings_group` INTO @earnings_group FROM `db_position` WHERE id = NEW.position;
    SELECT `minimal_earnings` INTO @minimal_earnings FROM `db_earnings_group` WHERE id = @earnings_group;
    SELECT `maximal_earnings` INTO @maximal_earnings FROM `db_earnings_group` WHERE id = @earnings_group;
	IF NEW.earnings > @minimal_earnings AND NEW.earnings <= @maximal_earnings THEN
		SET @description = CONCAT(@description,'New wages of new employee: ', NEW.earnings,'. All in group ranges.\n');
	ELSE
		SET @description = CONCAT(@description,'New wages of new employee: ', NEW.earnings,', although from group affiliation, should be in the range (',@minimal_earnings,' to ',@maximal_earnings,'). Change group or earnings.\n');
	END IF;
	INSERT INTO `db_earnings_changes`(`id`,`user_id`, `information`, `creation_date`) VALUES (NULL, NEW.id, @description, @creation_date);
END
$$
DELIMITER ;
ALTER TABLE `db_users` 
	ADD CONSTRAINT `FK_db_users_db_position_K_id` FOREIGN KEY (`position`) REFERENCES `db_position`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_position` 
	ADD CONSTRAINT `FK_db_position_db_earnings_group_K_id` FOREIGN KEY (`earnings_group`) REFERENCES `db_earnings_group`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_user_resource_assign`
	ADD CONSTRAINT `FK_db_user_resource_assign_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_user_resource_assign_resources_K_id` FOREIGN KEY (`resource_id`) REFERENCES `db_resources`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `db_position_resource_assign` 
	ADD CONSTRAINT `FK_db_position_resource_assign_db_position_K_id` FOREIGN KEY (`position_id`) REFERENCES `db_position`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_position_resource_assign_resources_K_id` FOREIGN KEY (`resource_id`) REFERENCES `db_resources`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_user_holiday` 
	ADD CONSTRAINT `FK_db_user_holiday_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_position_skill_assign` 
	ADD CONSTRAINT `FK_db_position_skill_assign_db_position_K_id` FOREIGN KEY (`position_id`) REFERENCES `db_position`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_position_skill_assign_db_skill_matrix_K_id` FOREIGN KEY (`skill_id`) REFERENCES `db_skill_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_user_skill_assign` 
	ADD CONSTRAINT `FK_db_user_skill_assign_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_user_skill_assign_db_skill_matrix_K_id` FOREIGN KEY (`skill_id`) REFERENCES `db_skill_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_course_matrix` 
	ADD CONSTRAINT `FK_db_course_matrix_db_course_type_K_id` FOREIGN KEY (`type`) REFERENCES `db_course_type`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE `db_position_course_assign` 
	ADD CONSTRAINT `FK_db_position_course_assign_db_position_K_id` FOREIGN KEY (`position_id`) REFERENCES `db_position`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_position_course_assign_db_course_matrix_K_id` FOREIGN KEY (`course_id`) REFERENCES `db_course_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	

ALTER TABLE `db_user_course_assign` 
	ADD CONSTRAINT `FK_db_user_course_assign_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_user_course_assign_db_course_matrix_K_id` FOREIGN KEY (`course_id`) REFERENCES `db_course_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;	
	

ALTER TABLE `db_course_skill` 
	ADD CONSTRAINT `FK_db_course_skill_db_course_matrix_K_id` FOREIGN KEY (`course_id`) REFERENCES `db_course_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT `FK_db_course_skill_db_skill_matrix_K_id` FOREIGN KEY (`skill_id`) REFERENCES `db_skill_matrix`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;		
	
ALTER TABLE `db_earnings_changes` 
	ADD CONSTRAINT `FK_db_earnings_changes_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE `db_earnings_oversight` 
	ADD CONSTRAINT `FK_db_earnings_oversight_db_users_K_id` FOREIGN KEY (`user_id`) REFERENCES `db_users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
	
	
CREATE VIEW v_user_course_assign
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, `db_course_matrix`.`name`, `db_user_course_assign`.`status`
FROM `db_user_course_assign` 
JOIN `db_users` ON `db_user_course_assign`.`user_id` = `db_users`.`id`
JOIN `db_course_matrix` ON `db_user_course_assign`.`course_id` = `db_course_matrix`.`id`
WHERE 1;


CREATE VIEW v_user_resource_assign
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, `db_resources`.`name`, `db_user_resource_assign`.`status`
FROM `db_user_resource_assign` 
JOIN `db_users` ON `db_user_resource_assign`.`user_id` = `db_users`.`id`
JOIN `db_resources` ON `db_user_resource_assign`.`resource_id` = `db_resources`.`id`
WHERE 1;

CREATE VIEW v_user_skill_assign
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, `db_skill_matrix`.`name`, `db_user_skill_assign`.`status`
FROM `db_user_skill_assign` 
JOIN `db_users` ON `db_user_skill_assign`.`user_id` = `db_users`.`id`
JOIN `db_skill_matrix` ON `db_user_skill_assign`.`skill_id` = `db_skill_matrix`.`id`
WHERE 1;

CREATE VIEW v_user
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, `db_users`.`email`, `db_position`.`position_name`
FROM `db_users` 
JOIN `db_position` ON `db_position`.`id` = `db_users`.`position`
WHERE 1;

CREATE VIEW v_user_earnings_changes
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, `db_earnings_changes`.`information`
FROM `db_users` 
JOIN `db_earnings_changes` ON `db_earnings_changes`.`user_id` = `db_users`.`id`
WHERE 1;

CREATE VIEW v_user_earnings
AS
SELECT CONCAT(`hr_database`.`db_users`.`first_name`,' ', `hr_database`.`db_users`.`second_name`) AS `user`, db_users.earnings ,db_position.position_name, db_earnings_group.minimal_earnings, db_earnings_group.maximal_earnings
FROM `db_users`
JOIN db_position ON db_position.id = db_users.position
JOIN db_earnings_group ON db_earnings_group.id = db_position.earnings_group
WHERE 1