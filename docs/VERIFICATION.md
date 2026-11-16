# 검증 기록

검증일: 2026-11-16

|항목|결과|의미|
|---|---|---|
|uv lock / uv sync --frozen|성공|의존성 고정 및 설치|
|Python 3.12.14 + supabase 2.34.1|import 성공|SDK 로드 확인|
|unittest 8개|통과|테이블 선택·ID 필터·입력 안전장치 검증|
|python demo.py|DB 변경 없이 종료|명시 옵션 없이는 네트워크 쓰기 없음|
|실제 Supabase SDK CRUD|미실행|접속 권한 및 전용 실습 DB 준비 필요|
|SQL 및 제약조건|실제 Supabase PASS 8개|CREATE·READ JOIN·UPDATE·UNIQUE·CHECK·FK·RESTRICT·DELETE|
|실제 SQL 결과 화면|대시보드 확인, 파일 저장 전|스크린샷 파일 첨부 필요|

원본 노트북/.env/기존 데이터는 수정하지 않았다. 서버 키를 읽거나 복사하지 않았다. 배포·GitHub 업로드는 별도 절차다.

전용 실습 프로젝트에서 스키마 COMMIT 및 검증 SQL ROLLBACK 실행 성공. Python SDK 실서버 검증과 SQL 실증은 구분한다.
