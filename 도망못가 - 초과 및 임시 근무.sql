#임시근로 내역확인
SELECT r.recruit_index, wt.work_type_name, r.recruit_state, r.work_start, r.work_end, r.recruit_worker, r.applyment_worker FROM Recruit r
	LEFT JOIN work_type wt
    ON r.work_type_index = wt.work_type_index;
    
#근무 모집 생성
Insert Into Recruit(work_type_index, recruit_state, work_start, work_end, recruit_worker, applyment_worker) values (?, ?, ?, ?, ? ,?);

#초과 근무 신청
Insert Into Overtime(cover_state, user_index, recruit_index) values (0, ?, ?);

#초과 근무 승인
Update Overtime Set cover_state = 1 WHERE overtime_index = ?;

-- #결근 신청
Insert Into Absence(absence_state, absence_start, absence_end, user_index) values (?, ?, ?, ?);