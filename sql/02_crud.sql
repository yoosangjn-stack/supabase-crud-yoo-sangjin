-- 전용 실습 DB에서 블록 전체를 실행한다. 마지막 ROLLBACK으로 데이터 변경은 남지 않는다.
BEGIN;
CREATE TEMP TABLE demo_ids (kind text PRIMARY KEY, id bigint) ON COMMIT DROP;
WITH row AS (INSERT INTO public.ch2_members(name,email)
 VALUES ('SQL 실습회원','sql-' || gen_random_uuid()::text || '@example.com') RETURNING id)
 INSERT INTO demo_ids SELECT 'member',id FROM row;
WITH row AS (INSERT INTO public.ch2_products(name,price,stock)
 VALUES ('SQL 실습상품',5000,10) RETURNING id)
 INSERT INTO demo_ids SELECT 'product',id FROM row;
WITH row AS (INSERT INTO public.ch2_orders(member_id,product_id,quantity,unit_price)
 VALUES ((SELECT id FROM demo_ids WHERE kind='member'),(SELECT id FROM demo_ids WHERE kind='product'),2,5000) RETURNING id)
 INSERT INTO demo_ids SELECT 'order',id FROM row;
SELECT * FROM public.ch2_members WHERE id=(SELECT id FROM demo_ids WHERE kind='member');
SELECT * FROM public.ch2_products WHERE id=(SELECT id FROM demo_ids WHERE kind='product');
SELECT * FROM public.ch2_orders WHERE id=(SELECT id FROM demo_ids WHERE kind='order');
UPDATE public.ch2_members SET name='SQL 수정회원' WHERE id=(SELECT id FROM demo_ids WHERE kind='member') RETURNING *;
UPDATE public.ch2_products SET price=5500 WHERE id=(SELECT id FROM demo_ids WHERE kind='product') RETURNING *;
UPDATE public.ch2_orders SET quantity=3 WHERE id=(SELECT id FROM demo_ids WHERE kind='order') RETURNING *;
DELETE FROM public.ch2_orders WHERE id=(SELECT id FROM demo_ids WHERE kind='order') RETURNING *;
DELETE FROM public.ch2_products WHERE id=(SELECT id FROM demo_ids WHERE kind='product') RETURNING *;
DELETE FROM public.ch2_members WHERE id=(SELECT id FROM demo_ids WHERE kind='member') RETURNING *;
ROLLBACK;
-- COMMIT은 변경을 확정한다. 위 예제는 안전한 반복 실습을 위해 ROLLBACK을 사용한다.
-- ID 시퀀스 증가 자체는 롤백되지 않아 번호에 공백이 생길 수 있다.
