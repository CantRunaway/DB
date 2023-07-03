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
DELIMITER;

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

#출근 시 유저 상태 변경 및 로그에 추가, 수동 출근도 동일하게 사용
DELIMITER & 
CREATE PROCEDURE Diligence(
	PARAM_USER_ID VARCHAR(40),
    PARAM_WORK_TYPE_INDEX INT,
    PARAM_TIME TIMESTAMP
    )
    BEGIN
		UPDATE USER SET work_state = 1 WHERE user_id = PARAM_USER_ID;
        
        INSERT INTO commute_log(user_id, work_index, commute_time) values (PARAM_USER_ID, PARAM_WORK_TYPE_INDEX, PARAM_TIME);
	END;
DELIMITER;

#퇴근 시 유저 상태 변경 및 로그에 추가, 수동 퇴근도 동일하게 사용
#work 연속 시간값과 출근 시간 퇴근 시간 비교해서 schedule에서 시간 뽑아서 시간 유효성 검사 후 유효하면 그대로 select하고 유효하지않으면 초과근무여부확인 후 select
#연속 값 group by, 시작값 min group 종료값 max group 둘 사이의 차를 계산해서 

SELECT  FROM Stats;
DELIMITER & 
CREATE PROCEDURE Laziness(
	PARAM_USER_ID VARCHAR(40),
    PARAM_WORK_TYPE_INDEX INT,
    PARAM_TIME TIMESTAMP
    )
BEGIN
		UPDATE USER SET work_state = 2 WHERE user_id = PARAM_USER_ID;
        
		INSERT INTO commute_log(user_id, work_type_index, commute_time, commute_state) values (PARAM_USER_ID, PARAM_WORK_TYPE_INDEX, PARAM_TIME, 2);
        
        CALL insert_stat_by_laziness(PARAM_USER_ID, PARAM_TIME, PARAM_WORK_TYPE_INDEX);
	END;
DELIMITER;



CALL laziness('20200032', '2022-12-08 19:00:00');

DELIMITER &
CREATE PROCEDURE insert_stat_by_laziness(
	PARAM_USER_ID VARCHAR(40),
    PARAM_DATE TIMESTAMP,
    PARAM_WORK_TYPE_INDEX INT
)
	BEGIN
		DECLARE VAR_TIME TIME;
        DECLARE VAR_USER_INDEX int;
        DECLARE VAR_ORIGIN_START time;
        DECLARE VAR_ORIGIN_END time;
        DECLARE VAR_COMPARE_START time;
        DECLARE VAR_COMPARE_END time;
        DECLARE VAR_WORKTIME int;
        DECLARE VAR_HOUR_WAGE int;
        DECLARE VAR_WAGE int;
        DECLARE VAR_CHECK int;
        
		SET VAR_TIME = '15:30:00';
        SET VAR_USER_INDEX = (SELECT user_index FROM user WHERE user_id = PARAM_USER_ID);

		SET VAR_ORIGIN_START = (SELECT min(start_time) FROM schedule s
								JOIN work w
								ON s.schedule_index = w.schedule_index
								WHERE w.user_index = VAR_USER_INDEX
                                AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN start_time < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN start_time > VAR_TIME END)
                                AND weekday(PARAM_DATE) = (CASE WHEN w.work_day = '일' THEN 6 WHEN w.work_day = '월' THEN 0 WHEN w.work_day = '화' THEN 1 WHEN w.work_day = '수' THEN 2 
													 WHEN w.work_day = '목' THEN 3 WHEN w.work_day = '금' THEN 4 WHEN w.work_day = '토' THEN 5 END));
                                                     
		SET VAR_ORIGIN_END = (SELECT max(end_time) FROM schedule s
								JOIN work w
								ON s.schedule_index = w.schedule_index
								WHERE w.user_index = VAR_USER_INDEX
                                AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN start_time < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN start_time > VAR_TIME END)
                                AND weekday(PARAM_DATE) = (CASE WHEN w.work_day = '일' THEN 6 WHEN w.work_day = '월' THEN 0 WHEN w.work_day = '화' THEN 1 WHEN w.work_day = '수' THEN 2 
													 WHEN w.work_day = '목' THEN 3 WHEN w.work_day = '금' THEN 4 WHEN w.work_day = '토' THEN 5 END));
		
        SET VAR_COMPARE_START = (SELECT (CASE WHEN VAR_ORIGIN_START IS NULL THEN (SELECT time(work_start) FROM recruit r
									JOIN overtime o
									ON o.recruit_index = r.recruit_index
									WHERE date(r.work_start) = date(PARAM_DATE)
									AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN time(r.work_start) < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN time(r.work_start) > VAR_TIME END)
									AND o.user_index = VAR_USER_INDEX) ELSE VAR_ORIGIN_START END)); 
                                            
		SET VAR_COMPARE_END = (SELECT (CASE WHEN VAR_ORIGIN_END IS NULL THEN (SELECT time(work_end) FROM recruit r
								JOIN overtime o
								ON o.recruit_index = r.recruit_index
								WHERE date(r.work_start) = date(PARAM_DATE)
								AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN time(r.work_start) < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN time(r.work_start) > VAR_TIME END)
								AND o.user_index = VAR_USER_INDEX) ELSE VAR_ORIGIN_END END)); 
                                
        SET VAR_WORKTIME = (hour(VAR_COMPARE_END) - hour(VAR_COMPARE_START));
        
        SET VAR_HOUR_WAGE = (SELECT hour_wage FROM wage WHERE change_date < PARAM_DATE AND work_type_index = PARAM_WORK_TYPE_INDEX ORDER BY change_date DESC LIMIT 1);
        
		SET VAR_WAGE = (VAR_WORKTIME * VAR_HOUR_WAGE);
        
        SET VAR_CHECK = (SELECT stats_index FROM stats WHERE user_id = PARAM_USER_ID AND `date` = date(PARAM_DATE));
        
        CALL add_hour_and_wage(PARAM_DATE, PARAM_USER_ID, VAR_CHECK, VAR_WORKTIME, VAR_WAGE);
	END;
DELIMITER;

DELIMITER &
CREATE PROCEDURE add_hour_and_wage(
	PARAM_DATE timestamp,
    PARAM_USER_ID VARCHAR(40),
    VAR_CHECK INT,
    VAR_WORKTIME INT,
    VAR_WAGE INT
	)
	BEGIN
		IF VAR_CHECK IS NOT NULL THEN
			UPDATE stats SET `hour` = `hour` + VAR_WORKTIME, wage = wage + VAR_WAGE WHERE user_id = PARAM_USER_ID AND `date` = date(PARAM_DATE);
		ELSE 
			INSERT INTO stats (user_id, hour, wage, `date`) VALUES (PARAM_USER_ID, VAR_WORKTIME, VAR_WAGE, date(PARAM_DATE));
		END IF;
	END;
DELIMITER;

DELIMITER & 
CREATE PROCEDURE self_Laziness(
	PARAM_USER_ID VARCHAR(40),
    PARAM_WORK_TYPE_INDEX INT,
    PARAM_TIME TIMESTAMP
    )
BEGIN
		UPDATE USER SET work_state = 2 WHERE user_id = PARAM_USER_ID;
        
		INSERT INTO commute_log(user_id, work_type_index, commute_time, commute_state) values (PARAM_USER_ID, PARAM_WORK_TYPE_INDEX, PARAM_TIME, 2);
        
        CALL self_insert_stat_by_laziness(PARAM_USER_ID, PARAM_TIME, PARAM_WORK_TYPE_INDEX);
	END;
DELIMITER;

DELIMITER &
CREATE PROCEDURE self_insert_stat_by_laziness(
	PARAM_USER_ID VARCHAR(40),
    PARAM_DATE TIMESTAMP,
    PARAM_WORK_TYPE_INDEX INT
)
	BEGIN
		DECLARE VAR_TIME TIME;
        DECLARE VAR_USER_INDEX int;
        DECLARE VAR_ORIGIN_START time;
        DECLARE VAR_ORIGIN_END time;
        DECLARE VAR_WORKTIME int;
        DECLARE VAR_HOUR_WAGE int;
        DECLARE VAR_WAGE int;
        DECLARE VAR_CHECK int;
        
		SET VAR_TIME = '15:30:00';
        SET VAR_USER_INDEX = (SELECT user_index FROM user WHERE user_id = PARAM_USER_ID);

		SET VAR_ORIGIN_START = (SELECT min(start_time) FROM schedule s
								JOIN work w
								ON s.schedule_index = w.schedule_index
								WHERE w.user_index = VAR_USER_INDEX
                                AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN start_time < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN start_time > VAR_TIME END)
                                AND weekday(PARAM_DATE) = (CASE WHEN w.work_day = '일' THEN 6 WHEN w.work_day = '월' THEN 0 WHEN w.work_day = '화' THEN 1 WHEN w.work_day = '수' THEN 2 
													 WHEN w.work_day = '목' THEN 3 WHEN w.work_day = '금' THEN 4 WHEN w.work_day = '토' THEN 5 END));
                                                     
		SET VAR_ORIGIN_END = (SELECT max(end_time) FROM schedule s
								JOIN work w
								ON s.schedule_index = w.schedule_index
								WHERE w.user_index = VAR_USER_INDEX
                                AND (CASE WHEN time(PARAM_DATE) < VAR_TIME THEN start_time < VAR_TIME WHEN time(PARAM_DATE) > VAR_TIME THEN start_time > VAR_TIME END)
                                AND weekday(PARAM_DATE) = (CASE WHEN w.work_day = '일' THEN 6 WHEN w.work_day = '월' THEN 0 WHEN w.work_day = '화' THEN 1 WHEN w.work_day = '수' THEN 2 
													 WHEN w.work_day = '목' THEN 3 WHEN w.work_day = '금' THEN 4 WHEN w.work_day = '토' THEN 5 END));
                                
        SET VAR_WORKTIME = (hour(VAR_ORIGIN_END) - hour(VAR_ORIGIN_START));
        
        SET VAR_HOUR_WAGE = (SELECT hour_wage FROM wage WHERE change_date < PARAM_DATE AND work_type_index = PARAM_WORK_TYPE_INDEX ORDER BY change_date DESC LIMIT 1);
        
		SET VAR_WAGE = (VAR_WORKTIME * VAR_HOUR_WAGE);
        
        SET VAR_CHECK = (SELECT stats_index FROM stats WHERE user_id = PARAM_USER_ID AND `date` = date(PARAM_DATE));
        
        CALL self_add_hour_and_wage(PARAM_DATE, PARAM_USER_ID, VAR_CHECK, VAR_WORKTIME, VAR_WAGE);
	END;
DELIMITER;


DELIMITER &
CREATE PROCEDURE self_add_hour_and_wage(
	PARAM_DATE timestamp,
    PARAM_USER_ID VARCHAR(40),
    VAR_CHECK INT,
    VAR_WORKTIME INT,
    VAR_WAGE INT
	)
	BEGIN
		IF VAR_CHECK IS NOT NULL THEN
			UPDATE stats SET `hour` = `hour` + VAR_WORKTIME, wage = wage + VAR_WAGE WHERE user_id = PARAM_USER_ID AND `date` = date(PARAM_DATE);
		ELSE 
			INSERT INTO stats (user_id, hour, wage, `date`) VALUES (PARAM_USER_ID, VAR_WORKTIME, VAR_WAGE, date(PARAM_DATE));
		END IF;
	END;
DELIMITER;

#자정마다 출근상태인 유저들을 퇴근상태로 변경
CREATE EVENT event_daily_convert_Diligence_to_Laziness
	ON SCHEDULE EVERY 1 DAY
    STARTS '2022-11-24 00:00:00'
	ON COMPLETION PRESERVE
    DO
	UPDATE USER SET work_state = 2
    WHERE work_state = 1;

#이벤트 조회    
SELECT * FROM information_schema.events;

SHOW VARIABLES LIKE 'event%';