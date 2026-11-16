BEGIN;
CREATE TEMP TABLE verification_results(step text, result text) ON COMMIT DROP;
DO $$
DECLARE m bigint; p bigint; o bigint; n integer;
BEGIN
 INSERT INTO public.ch2_members(name,email) VALUES('검증회원','verify-'||gen_random_uuid()::text||'@example.com') RETURNING id INTO m;
 INSERT INTO public.ch2_products(name,price,stock) VALUES('검증상품',5000,10) RETURNING id INTO p;
 INSERT INTO public.ch2_orders(member_id,product_id,quantity,unit_price) VALUES(m,p,2,5000) RETURNING id INTO o;
 INSERT INTO verification_results VALUES('01 CREATE','PASS: members/products/orders');
 SELECT count(*) INTO n FROM public.ch2_orders a JOIN public.ch2_members b ON a.member_id=b.id JOIN public.ch2_products c ON a.product_id=c.id WHERE a.id=o;
 IF n<>1 THEN RAISE EXCEPTION 'READ failed'; END IF;
 INSERT INTO verification_results VALUES('02 READ JOIN','PASS: member-product-order relation');
 UPDATE public.ch2_members SET name='수정회원' WHERE id=m;
 UPDATE public.ch2_products SET price=5500 WHERE id=p;
 UPDATE public.ch2_orders SET quantity=3 WHERE id=o;
 IF NOT EXISTS(SELECT 1 FROM public.ch2_members WHERE id=m AND name='수정회원') OR NOT EXISTS(SELECT 1 FROM public.ch2_products WHERE id=p AND price=5500) OR NOT EXISTS(SELECT 1 FROM public.ch2_orders WHERE id=o AND quantity=3 AND unit_price=5000) THEN RAISE EXCEPTION 'UPDATE failed'; END IF;
 INSERT INTO verification_results VALUES('03 UPDATE','PASS: three tables; order price preserved');
 BEGIN
  INSERT INTO public.ch2_members(name,email) SELECT name,email FROM public.ch2_members WHERE id=m;
  RAISE EXCEPTION 'UNIQUE failed';
 EXCEPTION WHEN unique_violation THEN INSERT INTO verification_results VALUES('04 UNIQUE','PASS: duplicate email rejected'); END;
 BEGIN
  UPDATE public.ch2_orders SET quantity=0 WHERE id=o;
  RAISE EXCEPTION 'CHECK failed';
 EXCEPTION WHEN check_violation THEN INSERT INTO verification_results VALUES('05 CHECK','PASS: quantity zero rejected'); END;
 BEGIN
  UPDATE public.ch2_orders SET member_id=-1 WHERE id=o;
  RAISE EXCEPTION 'FK failed';
 EXCEPTION WHEN foreign_key_violation THEN INSERT INTO verification_results VALUES('06 FK','PASS: missing member rejected'); END;
 BEGIN
  DELETE FROM public.ch2_members WHERE id=m;
  RAISE EXCEPTION 'RESTRICT failed';
 EXCEPTION WHEN foreign_key_violation THEN INSERT INTO verification_results VALUES('07 RESTRICT','PASS: parent deletion rejected'); END;
 DELETE FROM public.ch2_orders WHERE id=o;
 DELETE FROM public.ch2_products WHERE id=p;
 DELETE FROM public.ch2_members WHERE id=m;
 IF EXISTS(SELECT 1 FROM public.ch2_orders WHERE id=o) OR EXISTS(SELECT 1 FROM public.ch2_products WHERE id=p) OR EXISTS(SELECT 1 FROM public.ch2_members WHERE id=m) THEN RAISE EXCEPTION 'DELETE failed'; END IF;
 INSERT INTO verification_results VALUES('08 DELETE','PASS: generated rows removed');
END $$;
SELECT * FROM verification_results ORDER BY step;
ROLLBACK;
