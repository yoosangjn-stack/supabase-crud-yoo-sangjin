-- 전용 과제 프로젝트에서 승인 후 한 번만 실행한다. 이미 적용한 프로젝트는 재실행 금지.
-- SQL 02/03 검증을 먼저 완료한다. 기존 행은 변경·삭제하지 않는다.
BEGIN;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.ch2_members) OR EXISTS (SELECT 1 FROM public.ch2_products) OR EXISTS (SELECT 1 FROM public.ch2_orders) THEN
    RAISE EXCEPTION '기존 행이 있습니다. 변경 없이 중단합니다.';
  END IF;
END $$;
ALTER TABLE public.ch2_members ADD COLUMN owner_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id);
ALTER TABLE public.ch2_products ADD COLUMN owner_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id);
ALTER TABLE public.ch2_orders ADD COLUMN owner_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id);
ALTER TABLE public.ch2_members ADD CONSTRAINT ch2_members_id_owner UNIQUE(id,owner_id);
ALTER TABLE public.ch2_products ADD CONSTRAINT ch2_products_id_owner UNIQUE(id,owner_id);
ALTER TABLE public.ch2_orders ADD CONSTRAINT ch2_order_member_owner_fk FOREIGN KEY(member_id,owner_id) REFERENCES public.ch2_members(id,owner_id);
ALTER TABLE public.ch2_orders ADD CONSTRAINT ch2_order_product_owner_fk FOREIGN KEY(product_id,owner_id) REFERENCES public.ch2_products(id,owner_id);
CREATE POLICY ch2_members_owner ON public.ch2_members FOR ALL TO authenticated USING ((SELECT auth.uid())=owner_id) WITH CHECK ((SELECT auth.uid())=owner_id);
CREATE POLICY ch2_products_owner ON public.ch2_products FOR ALL TO authenticated USING ((SELECT auth.uid())=owner_id) WITH CHECK ((SELECT auth.uid())=owner_id);
CREATE POLICY ch2_orders_owner ON public.ch2_orders FOR ALL TO authenticated USING ((SELECT auth.uid())=owner_id) WITH CHECK ((SELECT auth.uid())=owner_id);
REVOKE ALL ON public.ch2_members,public.ch2_products,public.ch2_orders FROM anon;
GRANT SELECT,INSERT,UPDATE,DELETE ON public.ch2_members,public.ch2_products,public.ch2_orders TO authenticated;
GRANT USAGE,SELECT ON SEQUENCE public.ch2_members_id_seq,public.ch2_products_id_seq,public.ch2_orders_id_seq TO authenticated;
COMMIT;
