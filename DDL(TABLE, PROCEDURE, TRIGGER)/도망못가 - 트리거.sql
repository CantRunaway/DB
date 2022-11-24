# 결근 상태 수락으로 바꾸면 자동으로 근무 모집 생성
DELIMITER $
CREATE TRIGGER Make_Recruit_By_Absence
	AFTER UPDATE
    ON Absence
    FOR EACH ROW
    BEGIN
		IF new.absence_state = 1 THEN
		INSERT INTO Recruit(work_type_index, recruit_state, work_start, work_end, recruit_worker, applyment_worker) 
			values ((SELECT work_type_index FROM User WHERE user_index = old.user_index), 1,  new.absence_start, new.absence_end, 1, 0);
		END IF;
	END;
DELIMETER ;

# 초과 근무 승인 시 신청 인원 증가하고 가득 찰 경우 모집 완료
DELIMITER $
CREATE TRIGGER Complete_Apply_Recruit
	AFTER UPDATE
    ON Overtime
    FOR EACH ROW
    BEGIN
	IF new.cover_state = 1 THEN
        CALL UpdateRecruit(new.recruit_index);
        END IF;
	END;
DELIMITER;
