"""수업의 table → CRUD → execute 흐름을 세 테이블에 동일하게 적용한다."""

TABLES = {"members": "ch2_members", "products": "ch2_products", "orders": "ch2_orders"}


class CrudService:
    def __init__(self, client, resource):
        if resource not in TABLES:
            raise ValueError("members, products, orders 중 하나를 선택하세요.")
        self.client = client
        self.table = TABLES[resource]

    @staticmethod
    def check_id(row_id):
        if type(row_id) is not int or row_id < 1:
            raise ValueError("ID는 1 이상의 정수여야 합니다.")

    def create(self, data):
        if not data or "id" in data:
            raise ValueError("생성할 필드를 입력하세요. ID는 DB가 생성합니다.")
        return self.client.table(self.table).insert(data).execute().data

    def read(self, row_id):
        self.check_id(row_id)
        return self.client.table(self.table).select("*").eq("id", row_id).execute().data

    def update(self, row_id, data):
        self.check_id(row_id)
        if not data or "id" in data:
            raise ValueError("수정할 필드를 입력하세요. ID는 변경할 수 없습니다.")
        return self.client.table(self.table).update(data).eq("id", row_id).execute().data

    def delete(self, row_id):
        self.check_id(row_id)
        return self.client.table(self.table).delete().eq("id", row_id).execute().data
