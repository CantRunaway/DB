#임시근로 내역 확인
SELECT r.recruit_index, wt.work_type_name, r.recruit_state, r.work_start, r.work_end, r.recruit_worker, r.applyment_worker FROM Recruit r
	LEFT JOIN work_type wt
    ON r.work_type_index = wt.work_type_index;
    
#오늘 시간이 내가 근무뛰는 날인지 아닌지
SELECT * FROM Recruit r
	LEFT JOIN overtime o
    ON r.recruit_index = o.recruit_index
    WHERE o.user_index = 2
    AND ;
    
    
SELECT * FROM commute_log;    

#임시근로 신청내역 확인
SELECT * FROM Overtime;

#임시근로 요청 승인 / 0 미승인 1 승인 2 거부
UPDATE Overtime SET cover_state = 1 WHERE user_index = ? AND recruit_index = ?;

#임시근로 요청 거부
UPDATE Overtime SET cover_state = 2 WHERE user_index = ? AND recruit_index = ?;
    
#임시근무 모집 생성
Insert Into Recruit(work_type_index, work_start, work_end, recruit_worker, applyment_worker) values (?, ?, ?, ? ,?);

#임시근무 모집 삭제
DELETE FROM Recruit WHERE recruit_index = ?;

#출퇴근 수동 등록 - 프로시저화 -> log와 user 같이 insert update

#초과 근무(임시 근로) 신청
Insert Into Overtime(cover_state, user_index, recruit_index) values (0, ?, ?);

#결근 신청
Insert Into Absence(absence_state, absence_start, absence_end, user_index) values (?, ?, ?, ?);

#출근 - 프로시저화 - log도 찍어야함
UPDATE USER SET work_state = 1 WHERE user_id = ?;

#퇴근 = 미근무 - log도 찍어야함
UPDATE USER SET work_state = 0 WHERE user_id = ?;

#출근 시 유저 상태 변경 및 로그에 추가, 수동 출근도 동일하게 사용
DELIMITER & 
CREATE PROCEDURE Diligence(
	PARAM_USER_ID VARCHAR(40),
    PARAM_WORK_INDEX INT,
    PARAM_TIME TIMESTAMP
    )
    BEGIN
		UPDATE USER SET work_state = 1 WHERE user_id = PARAM_USER_ID;
        
        INSERT INTO commute_log(user_id, work_index, commute_time) values (PARAM_USER_ID, PARAM_WORK_INDEX, PARAM_TIME);
	END;
DELIMITER;

#퇴근 시 유저 상태 변경 및 로그에 추가, 수동 퇴근도 동일하게 사용
DELIMITER & 
CREATE PROCEDURE Laziness(
	PARAM_USER_ID VARCHAR(40),
    PARAM_WORK_INDEX INT,
    PARAM_TIME TIMESTAMP
    )
    BEGIN
		UPDATE USER SET work_state = 0 WHERE user_id = PARAM_USER_ID;
        
        INSERT INTO commute_log(user_id, work_index, commute_time) values (PARAM_USER_ID, PARAM_WORK_INDEX, PARAM_TIME);
	END;
DELIMITER;

#임금 통계 달마다
SELECT SUM(hour), SUM(wage) FROM stats
	WHERE user_index = 2
	AND date between DATE_FORMAT(CONCAT(DATE_FORMAT( NOW(),'%Y-%m'),'-1'),'%Y-%m-%d') AND LAST_DAY(NOW()) + INTERVAL 1 DAY; 


SELECT * FROM USER;

SELECT * FROM commute_log;