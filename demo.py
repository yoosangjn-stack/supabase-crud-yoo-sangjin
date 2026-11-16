"""빈 실습 프로젝트에서만 실행. 이 프로그램은 실제 DB 쓰기를 수행합니다."""
import argparse
import os
from uuid import uuid4
from crud import CrudService


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-demo", action="store_true", help="실습 DB의 쓰기/삭제를 명시적으로 허용")
    args = parser.parse_args()
    if not args.run_demo:
        parser.exit(message="DB 변경 없음. 전용 실습 프로젝트 준비 후 --run-demo를 사용하세요.\n")
    from dotenv import load_dotenv
    from supabase import create_client
    load_dotenv()
    url, key = os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY")
    if not url or not key:
        raise SystemExit(".env에 전용 실습 프로젝트의 URL과 서버 키를 설정하세요.")
    client = create_client(url, key)
    members, products, orders = [CrudService(client, name) for name in ("members", "products", "orders")]
    tag = uuid4().hex[:12]
    # 기존 데이터가 아니라 이 실행에서 만든 레코드만 수정·삭제한다.
    member = members.create({"name": "실습회원", "email": f"demo-{tag}@example.com"})[0]
    print("CREATE member:", member)
    product = products.create({"name": f"실습상품-{tag}", "price": 5000, "stock": 10})[0]
    print("CREATE product:", product)
    order = orders.create({"member_id": member["id"], "product_id": product["id"], "quantity": 2, "unit_price": 5000})[0]
    print("CREATE order:", order)
    for service, row in ((members, member), (products, product), (orders, order)):
        actual = service.read(row["id"])
        assert len(actual) == 1 and actual[0]["id"] == row["id"]
        print("READ verified", service.table, actual)
    for service, row, changes in ((members, member, {"name": "수정회원"}), (products, product, {"price": 5500}), (orders, order, {"quantity": 3})):
        service.update(row["id"], changes)
        actual = service.read(row["id"])
        assert actual and all(actual[0][key] == value for key, value in changes.items())
        print("UPDATE verified", service.table, actual)
    for service, row in ((orders, order), (products, product), (members, member)):
        service.delete(row["id"])
        assert service.read(row["id"]) == []
        print("DELETE verified", service.table, row["id"])
    print("세 테이블 CRUD 검증 완료")


if __name__ == "__main__":
    main()
