-- 읽기 전용. 이미 정책이 적용됐다면 04를 재실행하지 않는다.
SELECT 'ch2_members' AS table_name, count(*) AS row_count FROM public.ch2_members
UNION ALL SELECT 'ch2_products', count(*) FROM public.ch2_products
UNION ALL SELECT 'ch2_orders', count(*) FROM public.ch2_orders;
SELECT table_name,column_name,is_nullable,column_default FROM information_schema.columns
WHERE table_schema='public' AND table_name IN ('ch2_members','ch2_products','ch2_orders') AND column_name='owner_id';
SELECT tablename,policyname,roles,cmd,qual,with_check FROM pg_policies
WHERE schemaname='public' AND tablename IN ('ch2_members','ch2_products','ch2_orders');
