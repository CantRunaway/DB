#사용자 정보 수정
Update User set 
password = CASE WHEN md5(?) != password AND ? IS NOT NULL THEN md5(?) ELSE password END, 
name = CASE WHEN ? != name AND ? IS NOT NULL THEN ? ELSE name END,
grade = CASE WHEN ? != grade AND ? IS NOT NULL THEN ? ELSE grade END,
phone = CASE WHEN ? != hex(aes_encrypt('?', 'dlsrhdwlsmd')) AND ? IS NOT NULL THEN hex(aes_encrypt('?', 'dlsrhdwlsmd')) ELSE phone END,
account = CASE WHEN ? != hex(aes_encrypt('?', 'dlsrhdwlsmd')) AND ? IS NOT NULL THEN hex(aes_encrypt('?', 'dlsrhdwlsmd')) ELSE account END,
birth = CASE WHEN ? != birth AND ? IS NOT NULL THEN ? ELSE birth END,
work_type_index = CASE WHEN ? != work_type_index IS NOT NULL THEN ? ELSE work_type_index END,
bank_index = CASE WHEN ? != bank_index IS NOT NULL THEN ? ELSE bank_index END,
department_index = CASE WHEN ? != department_index IS NOT NULL THEN ? ELSE department_index END
Where `account` = ? and `password` = ?;

#pw 검증
Select exists (select user_index from User where user_id = ? and `password` = md5(?)) as exist;

######################

#사용자 정보 조회 - 리스트
Select user_id, `name`, grade, convert(aes_decrypt(unhex(phone), 'dlsrhdwlsmd') using utf8) as 'phone', convert(aes_decrypt(unhex(account), 'dlsrhdwlsmd') using utf8) as 'account', date_format(birth, '%Y-%m-%d') as birth, wt.work_type_name, b.bank_name from User u
	Join work_type wt, bank b
    Where u.work_type_index = wt.work_type_index
    And u.bank_index = b.bank_index
    And u.user_type = 2;

#사용자 정보 조회 - 개인
Select user_id, `name`, grade, convert(aes_decrypt(unhex(phone), 'dlsrhdwlsmd') using utf8) as 'phone', convert(aes_decrypt(unhex(account), 'dlsrhdwlsmd') using utf8) as 'account', date_format(birth, '%Y-%m-%d') as birth, wt.work_type_name, b.bank_name from User u
	Join work_type wt, bank b
    Where u.work_type_index = wt.work_type_index
    And u.bank_index = b.bank_index
    And u.user_type = 2
    And u.name = '강태혁';

######################

#근로자 삭제
Delete From User Where user_id = ?;

######################

#근로자 정보 조회

select user_id, convert(aes_decrypt(unhex(account), 'dlsrhdwlsmd') using utf8) as account, convert(aes_decrypt(unhex(phone), 'dlsrhdwlsmd') using utf8) as phone from user;
