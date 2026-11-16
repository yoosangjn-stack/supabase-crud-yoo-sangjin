import unittest
from unittest.mock import MagicMock
from crud import CrudService


class CrudTests(unittest.TestCase):
    def setUp(self):
        self.client = MagicMock()
        self.service = CrudService(self.client, "members")

    def test_create(self):
        self.service.create({"name": "연습"})
        self.client.table.assert_called_with("ch2_members")
        self.client.table.return_value.insert.assert_called_once_with({"name": "연습"})

    def test_read_filter(self):
        self.service.read(7)
        self.client.table.return_value.select.return_value.eq.assert_called_once_with("id", 7)

    def test_update_filter(self):
        self.service.update(7, {"name": "변경"})
        self.client.table.return_value.update.return_value.eq.assert_called_once_with("id", 7)

    def test_delete_filter(self):
        self.service.delete(7)
        self.client.table.return_value.delete.return_value.eq.assert_called_once_with("id", 7)

    def test_unknown_table(self):
        with self.assertRaises(ValueError):
            CrudService(self.client, "other")

    def test_invalid_ids(self):
        for value in (None, 0, -1, True, "1"):
            for operation in (self.service.read, self.service.delete):
                with self.assertRaises(ValueError):
                    operation(value)
        self.client.table.assert_not_called()

    def test_no_primary_key_change(self):
        with self.assertRaises(ValueError):
            self.service.update(1, {"id": 2})
        with self.assertRaises(ValueError):
            self.service.create({"id": 1})
        self.client.table.assert_not_called()

    def test_all_resources(self):
        for name in ("members", "products", "orders"):
            self.assertEqual(CrudService(self.client, name).table, "ch2_" + name)


if __name__ == "__main__":
    unittest.main()
