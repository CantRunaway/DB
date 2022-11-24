CREATE TABLE `User` (
	`user_index`	INT	NOT NULL Auto_Increment primary Key,
	`user_id`	varchar(20)	not NULL,
	`password`	varchar(20)	not NULL,
	`user_type`	TINYINT	not NULL,
	`name`	varchar(20)	not NULL,
	`grade`	INT	NULL,
	`phone`	varchar(20)	not NULL,
	`account`	varchar(40)	NULL,
	`birth`	TIMESTAMP	NULL,
	`registration_state`	TINYINT	not NULL,
	`work_state`	TINYINT	NULL,
	`work__type_index`	INT	NOT NULL,
	`bank_index`	INT	NOT NULL,
	`department_index`	INT	NOT NULL
);

CREATE TABLE `bank` (
	`bank_index`	INT	NOT NULL Auto_Increment primary Key,
	`bank_name`	varchar(20)	not NULL
);

CREATE TABLE `department` (
	`department_index`	INT	NOT NULL Auto_Increment primary Key,
	`department_name`	varchar(20)	not NULL
);

CREATE TABLE `work_type` (
	`work_type_index`	INT	NOT NULL Auto_Increment primary Key,
	`work_type_name`	varchar(20)	not NULL
);

CREATE TABLE `Wage` (
	`wage_index`	INT	NOT NULL Auto_Increment primary Key,
	`work_type_index`	INT	NOT NULL,
	`change_date`	TIMESTAMP	NULL,
	`hour_wage`	INT	not NULL
);

CREATE TABLE `Commute_log` (
	`commute_log_index`	INT	NOT NULL Auto_Increment primary Key,
	`user_id`	varchar(20)	NULL,
	`work_index`	INT	NULL,
	`commute_time`	TIMESTAMP not NULL
);

CREATE TABLE `absence` (
	`absence_index`	INT	NOT NULL Auto_Increment primary Key,
	`work_index`	INT	NOT NULL,
	`absence_state`	TINYINT	not NULL,
	`absence_date`	DATE	not NULL
);

CREATE TABLE `Overtime` (
	`overtime_index`	INT	NOT NULL Auto_Increment primary Key,
	`cover_state`	TINYINT	NULL,
	`user_index`	INT	NOT NULL,
	`recruit_index`	INT	NOT NULL,
	`work_type_index`	INT	NOT NULL
);

CREATE TABLE `recruit` (
	`recruit_index`	INT	NOT NULL Auto_Increment primary Key,
	`work_type_index`	INT	NOT NULL,
	`recruit_state`	TINYINT	not NULL,
	`work_start`	TIMESTAMP	not NULL,
	`work_end`	TIMESTAMP	not NULL,
	`recruit_worker`	INT	not NULL,
	`applyment_worker`	INT	not NULL
);

CREATE TABLE `Schedule` (
	`Schedule_index`	INT	NOT NULL Auto_Increment primary Key,
	`start_time`	TIME	not NULL,
	`end_time`	TIME	not NULL
);

CREATE TABLE `Enrollment` (
	`enrollment_index`	int	NOT NULL Auto_Increment primary Key,
	`enrollment_day`	varchar(2)	NULL,
	`user_index`	INT	NOT NULL,
	`Schedule_index`	INT	NOT NULL
);

CREATE TABLE `work` (
	`work_index`	INT	NOT NULL Auto_Increment primary Key,
	`work_day`	varchar(2)	not NULL,
	`user_index`	INT	NOT NULL,
	`Schedule_index`	INT	NOT NULL
);

CREATE TABLE `Stats` (
	`stats_index`	INT	NOT NULL Auto_Increment primary Key,
	`user_index`	INT	NOT NULL,
	`hour`	INT	NULL,
	`wage`	INT	NULL,
	`day`	INT	NULL,
	`week`	INT	NULL,
	`month`	INT	NULL,
	`semester`	varchar(10)	NULL
);

CREATE TABLE `Edit_Schedule_Temporal` (
	`edit_schedule_temporal`	INT	NOT NULL Auto_Increment primary Key,
	`edit_start`	TIMESTAMP	not NULL,
	`edit_end`	TIMESTAMP	not NULL
);

ALTER TABLE `User` ADD CONSTRAINT `PK_USER` PRIMARY KEY (
	`user_index`
);

ALTER TABLE `bank` ADD CONSTRAINT `PK_BANK` PRIMARY KEY (
	`bank_index`
);

ALTER TABLE `department` ADD CONSTRAINT `PK_DEPARTMENT` PRIMARY KEY (
	`department_index`
);

ALTER TABLE `work_type` ADD CONSTRAINT `PK_WORK_TYPE` PRIMARY KEY (
	`work_type_index`
);

ALTER TABLE `Wage` ADD CONSTRAINT `PK_WAGE` PRIMARY KEY (
	`wage_index`,
	`work_type_index`
);

ALTER TABLE `Commute_log` ADD CONSTRAINT `PK_COMMUTE_LOG` PRIMARY KEY (
	`commute_log_index`
);

ALTER TABLE `absence` ADD CONSTRAINT `PK_ABSENCE` PRIMARY KEY (
	`absence_index`,
	`work_index`
);

ALTER TABLE `Overtime` ADD CONSTRAINT `PK_OVERTIME` PRIMARY KEY (
	`overtime_index`
);

ALTER TABLE `recruit` ADD CONSTRAINT `PK_RECRUIT` PRIMARY KEY (
	`recruit_index`,
	`work_type_index`
);

ALTER TABLE `Schedule` ADD CONSTRAINT `PK_SCHEDULE` PRIMARY KEY (
	`Schedule_index`
);

ALTER TABLE `Enrollment` ADD CONSTRAINT `PK_ENROLLMENT` PRIMARY KEY (
	`enrollment_index`
);

ALTER TABLE `work` ADD CONSTRAINT `PK_WORK` PRIMARY KEY (
	`work_index`
);

ALTER TABLE `Stats` ADD CONSTRAINT `PK_STATS` PRIMARY KEY (
	`stats_index`,
	`user_index`
);

ALTER TABLE `Edit_Schedule_Temporal` ADD CONSTRAINT `PK_EDIT_SCHEDULE_TEMPORAL` PRIMARY KEY (
	`edit_schedule_temporal`
);

ALTER TABLE `User` ADD CONSTRAINT `FK_work_type_TO_User_1` FOREIGN KEY (
	`work__type_index`
)
REFERENCES `work_type` (
	`work_type_index`
);

ALTER TABLE `User` ADD CONSTRAINT `FK_bank_TO_User_1` FOREIGN KEY (
	`bank_index`
)
REFERENCES `bank` (
	`bank_index`
);

ALTER TABLE `User` ADD CONSTRAINT `FK_department_TO_User_1` FOREIGN KEY (
	`department_index`
)
REFERENCES `department` (
	`department_index`
);

ALTER TABLE `Wage` ADD CONSTRAINT `FK_work_type_TO_Wage_1` FOREIGN KEY (
	`work_type_index`
)
REFERENCES `work_type` (
	`work_type_index`
);

ALTER TABLE `absence` ADD CONSTRAINT `FK_work_TO_absence_1` FOREIGN KEY (
	`work_index`
)
REFERENCES `work` (
	`work_index`
);

ALTER TABLE `Overtime` ADD CONSTRAINT `FK_User_TO_Overtime_1` FOREIGN KEY (
	`user_index`
)
REFERENCES `User` (
	`user_index`
);

ALTER TABLE `Overtime` ADD CONSTRAINT `FK_recruit_TO_Overtime_1` FOREIGN KEY (
	`recruit_index`
)
REFERENCES `recruit` (
	`recruit_index`
);

ALTER TABLE `Overtime` ADD CONSTRAINT `FK_recruit_TO_Overtime_2` FOREIGN KEY (
	`work_type_index`
)
REFERENCES `recruit` (
	`work_type_index`
);

ALTER TABLE `recruit` ADD CONSTRAINT `FK_work_type_TO_recruit_1` FOREIGN KEY (
	`work_type_index`
)
REFERENCES `work_type` (
	`work_type_index`
);

ALTER TABLE `Enrollment` ADD CONSTRAINT `FK_User_TO_Enrollment_1` FOREIGN KEY (
	`user_index`
)
REFERENCES `User` (
	`user_index`
);

ALTER TABLE `Enrollment` ADD CONSTRAINT `FK_Schedule_TO_Enrollment_1` FOREIGN KEY (
	`Schedule_index`
)
REFERENCES `Schedule` (
	`Schedule_index`
);

ALTER TABLE `work` ADD CONSTRAINT `FK_User_TO_work_1` FOREIGN KEY (
	`user_index`
)
REFERENCES `User` (
	`user_index`
);

ALTER TABLE `work` ADD CONSTRAINT `FK_Schedule_TO_work_1` FOREIGN KEY (
	`Schedule_index`
)
REFERENCES `Schedule` (
	`Schedule_index`
);

ALTER TABLE `Stats` ADD CONSTRAINT `FK_User_TO_Stats_1` FOREIGN KEY (
	`user_index`
)
REFERENCES `User` (
	`user_index`
);

