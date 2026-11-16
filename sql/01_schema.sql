-- 기존 프로젝트 대신 비어 있는 전용 실습 프로젝트에 실행한다.
-- 같은 이름의 테이블이 있으면 실패하도록 하여 잘못된 덮어쓰기를 막는다.
BEGIN;
CREATE TABLE public.ch2_members (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL CHECK (length(trim(name)) > 0),
  email text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.ch2_products (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL CHECK (length(trim(name)) > 0),
  price numeric(12,2) NOT NULL CHECK (price >= 0),
  stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0)
);
CREATE TABLE public.ch2_orders (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  member_id bigint NOT NULL REFERENCES public.ch2_members(id) ON DELETE RESTRICT,
  product_id bigint NOT NULL REFERENCES public.ch2_products(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','cancelled')),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON public.ch2_orders(member_id);
CREATE INDEX ON public.ch2_orders(product_id);
ALTER TABLE public.ch2_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ch2_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ch2_orders ENABLE ROW LEVEL SECURITY;
COMMIT;
-- 일반 anon/authenticated 접근 정책은 열지 않는다.
-- 본 과제는 서버 키를 쓰는 관리자 CLI 실습이며 사용자별 인증을 구현한 서비스가 아니다.
