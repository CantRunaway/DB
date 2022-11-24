# 근무 모집 인원이 가득 차면 모집 완료 -> 초과 근무 신청을 하고 신청 인원을 업데이트할때 업데이트 쿼리 호출이 아닌 프로시저 호출을 통해서 값을 증가시키고 조건 달성 시 상태 변경
DELIMITER $
CREATE PROCEDURE UpdateRecruit (
	PARAM_INDEX INT
    )
	BEGIN
	UPDATE Recruit SET applyment_num = applyment_num + 1,
    recruit_state = CASE WHEN recruit_num = applyment_num THEN 0 ELSE recruit_state END
    WHERE Recruit_index = PARAM_INDEX;
	END;
DELIMITER;

DELIMITER $
CREATE PROCEDURE UpdateRecruit_DELETE_OVERTIME (
	PARAM_INDEX INT
    )
	BEGIN
	UPDATE Recruit SET applyment_num = applyment_num + 1,
    recruit_state = CASE WHEN recruit_num = applyment_num THEN 0 ELSE recruit_state END
    WHERE Recruit_index = PARAM_INDEX;
	END;
DELIMITER;

#수업 시간이면 근로 시간에 안 들어감
DELIMITER $
CREATE PROCEDURE Compare_schedule(
	PARAM_USER INT,
    PARAM_DAY VARCHAR(2),
    PARAM_SCHEDULE INT
)
	BEGIN
		INSERT INTO Work(work_day, user_index, schedule_index)
        SELECT * FROM (SELECT PARAM_DAY , PARAM_USER , PARAM_SCHEDULE) AS en
        WHERE NOT EXISTS (
			SELECT * FROM Enrollment
			WHERE enrollment_day = PARAM_DAY
			AND user_index = PARAM_USER
			AND schedule_index = PARAM_SCHEDULE);
	END;
DELIMITER ;

# work_type 생성 시 wage에 최저임금 값으로 넣어주기
DELIMITER $
CREATE PROCEDURE Make_work_type_wage(
	PARAM_WORK_NAME VARCHAR(20),
	PARAM_DATE TIMESTAMP,
    PARAM_WAGE INT
)
	BEGIN
		INSERT INTO work_type(work_type_name) values (PARAM_WORK_NAME);
		
        INSERT INTO wage(work_type_index, change_date, hour_wage)
		values((SELECT work_type_index FROM work_type WHERE work_type_name = PARAM_WORK_NAME), PARAM_DATE, PARAM_WAGE); 
	END;
DELIMITER;