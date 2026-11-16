# 검증 기록

## 실제 Python SDK 검증

실제 서버 SDK 검증을 완료했다. 아래는 현재 확인된 결과이며 마감 전 완료를 주장하는 기록이 아니다.

- 별도 승인된 과제 EC2, Ubuntu 26.04.1, Python 3.14.4, 격리 venv, supabase 2.34.1, python-dotenv 1.2.4.
- main의 demo.py를 runpy로 실제 실행했다. 검증 래퍼는 승인된 가상 계정 암호를 암호화 SSH 표준입력으로 일시 전달하고 getpass 입력만 대체했다. 모의 DB가 아닌 실습 Supabase에 로그인했다.
- 공개용 키 + authenticated 소유자 정책 사용. 관리자 키 미사용. 비밀번호·토큰은 출력·로그·파일·GitHub에 저장하지 않았다.
- 생성한 행의 ID만 조회·수정·삭제했다. 래퍼가 해당 ID를 추적하여 finally에서 주문→상품→회원 순으로 잔여 행을 확인·정리하고 빈 조회를 재확인했다. 로그아웃 오류 없음.
- 최초 실행: 회원 3, 상품 2, 주문 2. 재검증: 회원 4, 상품 3, 주문 3. 모두 삭제 확인. 기존 행은 변경하지 않았다.

|항목|결과|
|---|---|
|EC2 단위 테스트|8개 PASS, 실서버 검증과 별도|
|회원 CRUD|CREATE / READ / UPDATE / DELETE PASS|
|상품 CRUD|CREATE / READ / UPDATE / DELETE PASS|
|주문 CRUD|CREATE / READ / UPDATE / DELETE PASS|
|생성 데이터 정리|세 테이블 대상 ID 빈 조회 확인 PASS|
|한글 데이터|회원·상품 생성값 왕복 일치 assertion PASS|
|SSH 실행|exit code 0|

### 실제 재검증 출력 발췌
아래는 실제 실행 출력에서 가상 행 내용·계정 식별자를 제외한 상태 줄이다. 화면 캡처를 대신하는 이미지나 재현 화면이 아니라 텍스트 증빙이다.

```text
UNICODE_ROUNDTRIP_PASS ch2_members
UNICODE_ROUNDTRIP_PASS ch2_products
READ verified ch2_members
READ verified ch2_products
READ verified ch2_orders
UPDATE verified ch2_members
UPDATE verified ch2_products
UPDATE verified ch2_orders
DELETE verified ch2_orders
DELETE verified ch2_products
DELETE verified ch2_members
CLEANUP_VERIFIED ch2_orders 3
CLEANUP_VERIFIED ch2_products 3
CLEANUP_VERIFIED ch2_members 4
FINAL_SDK_PASS=True
FINAL_CLEANUP_PASS=True
SSH_EXIT_CODE=0
```

최초 한글 출력 깨짐은 SSH 출력 수집 시 UTF-8을 명시해 개선했다. 저장소의 한글 소스는 정상이었으며 데이터 왕복도 재검증했다. Windows 실행 차단 정책은 변경하지 않았다.

## SQL 검증
전용 실습 프로젝트에서 스키마 COMMIT 및 검증 SQL ROLLBACK 성공. CREATE, READ JOIN, UPDATE, UNIQUE, CHECK, FK, RESTRICT, DELETE 8항목 PASS. 소유자 정책 3개 조회는 사용자가 직접 확인했다. 이번 SDK 검증에서 SQL을 재적용하지 않았다.

## 남은 증빙과 검증 범위
[PK/FK 실제 조회 캡처](screenshots/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%201.png)를 첨부했다. 세 테이블 PK와 주문의 회원·상품 FK가 보이지만 일부 긴 definition 오른쪽은 잘려 있다. SQL CRUD·제약조건 PASS 결과 화면은 아직 첨부되지 않았다. [SDK 실제 실행 화면](screenshots/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7.png)은 사용자가 직접 업로드했다. 해당 추가 실행도 CRUD 및 정리 PASS이며, 화면의 정리 대상은 회원 5·상품 4·주문 4이다. 위 텍스트는 앞선 실행 기록으로 ID가 다른 것은 정상이다. 두 사용자 간 접근 차단·익명 접근 거부를 이번 실행에서 별도로 시험한 것은 아니다. SDK 성공을 전체 RLS 공격 테스트 완료로 해석하지 않는다.
