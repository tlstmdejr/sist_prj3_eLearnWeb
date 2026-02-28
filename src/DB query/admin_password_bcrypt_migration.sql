-- ================================================
-- 관리자 비밀번호 BCrypt 마이그레이션 스크립트
-- AdminLoginService 가 BCrypt 검증으로 변경됨에 따라
-- MANAGER 테이블의 비밀번호를 BCrypt 해시로 교체해야 합니다.
--
-- BCrypt 해시값 생성 방법:
--   new BCryptPasswordEncoder().encode("원하는비밀번호")
--
-- 아래는 원래 평문 패스워드(pass01~pass10)를 BCrypt 해시로 변환한 예시입니다.
-- 실 운영 환경에서는 반드시 강력한 비밀번호를 사용하세요.
-- ================================================

-- 예시: pass01 에 대한 BCrypt 해시 ($2a$10$...)
-- UPDATE MANAGER SET PASSWORD = '$2a$10$HASH값' WHERE ADM_ID = 'admin1';

-- ❗ 운영 서버에 배포하기 전 아래 절차를 수행하세요:
-- 1. 새 비밀번호를 정합니다.
-- 2. BCryptPasswordEncoder.encode("새비밀번호") 로 해시를 생성합니다.
-- 3. 아래 UPDATE 문의 HASH값을 교체 후 실행합니다.

-- admin1 ~ admin10 비밀번호 업데이트 (각 관리자 계정별로 수행)
/*
UPDATE MANAGER SET PASSWORD = '$2a$10$<BCrypt해시>' WHERE ADM_ID = 'admin1';
UPDATE MANAGER SET PASSWORD = '$2a$10$<BCrypt해시>' WHERE ADM_ID = 'admin2';
UPDATE MANAGER SET PASSWORD = '$2a$10$<BCrypt해시>' WHERE ADM_ID = 'admin3';
UPDATE MANAGER SET PASSWORD = '$2a$10$<BCrypt해시>' WHERE ADM_ID = 'admin4';
UPDATE MANAGER SET PASSWORD = '$2a$10$<BCrypt해시>' WHERE ADM_ID = 'admin5';
COMMIT;
*/
