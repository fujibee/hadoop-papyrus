dsl 'HiveLike'

# hive-like/items.txt
# apple, 3, 100
# banana, 1, 50

create_table items(item STRING, quantity INT, price INT);
load_data "hive-like/items.txt" items;

select quantity, price, item from items;

# expect
# 0  apple 3 300
# 1  banana 1 50
