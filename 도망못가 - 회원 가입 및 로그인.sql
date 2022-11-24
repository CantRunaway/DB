#비밀번호는 조회 시 출력되는 값이 아니기에 단방향 암호 알고리즘인 md5 사용
#계좌번호 및 전화번호는 조회가 가능해야하지만 개인 정보이므로 aes 사용

#회원가입 요청
Insert Into User(user_id, `password`, user_type, `name`, grade, phone, `account`, birth, registration_state, work_type_index, bank_index, department_index) values ('20180283', md5('비밀번호'), 2, '김주호', 3,  hex(aes_encrypt('전화번호', '키 값')), hex(aes_encrypt('계좌번호', '키 값')) , '19990621',0,1,1, 1) ;

Insert Into User(user_id, `password`, user_type, `name`, grade, phone, `account`, birth, registration_state, work_type_index, bank_index, department_index) values (?, md5('?'), 2, ?, ?, hex(aes_encrypt('?', '키 값')),  hex(aes_encrypt('?', '키 값')), ?, 0, ?, ?, ?);

######################

#회원가입 승인
Update User set registration_state = 1 where user_id = 'test';

Update User set registration_state = 1 where user_id = ?;

######################

#회원요청 목록 조회
Select user_id, `name`, grade, convert(aes_decrypt(unhex(phone), '키 값') using utf8) as 'phone', convert(aes_decrypt(unhex(account), '키 값') using utf8) as 'account', birth, wt.work_type_name, b.bank_name from User u
	Join work_type wt, bank b
    Where u.work_type_index = wt.work_type_index
    And u.bank_index = b.bank_index
    And u.registration_state = 0;

######################

#로그인 - id값 존재 및 pw 일치 시 로그인 - 보류
Select exists (select user_index from User where user_id = 'test' and `password` = md5('비밀번호')) as exist;

Select exists (select user_index from User where user_id = ? and `password` = md5(?)) as exist;

######################

#로그아웃 - 쿼리 불 필요