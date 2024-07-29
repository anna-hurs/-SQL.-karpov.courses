/* Задача 1.
Для начала давайте проанализируем, насколько быстро растёт аудитория нашего сервиса, и посмотрим на динамику числа пользователей и курьеров. 
Задание:
Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:

Число новых пользователей.
Число новых курьеров.
Общее число пользователей на текущий день.
Общее число курьеров на текущий день.

Колонки с показателями назовите соответственно new_users, new_couriers, total_users, total_couriers. Колонку с датами назовите date. Проследите за тем, чтобы показатели были выражены целыми числами. Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers */

with users_num as (SELECT user_id,
                          time,
                          row_number() OVER (PARTITION BY user_id
                                             ORDER BY time) as num
                   FROM   user_actions
                   ORDER BY user_id), couriers_num as (SELECT courier_id,
                                           time,
                                           row_number() OVER (PARTITION BY courier_id
                                                              ORDER BY time) as num
                                    FROM   courier_actions
                                    ORDER BY courier_id), t1 as (SELECT time::date as date,
                                    count(user_id) as new_users,
                                    sum(count(user_id)) OVER (ORDER BY time::date)::integer as total_users
                             FROM   users_num
                             WHERE  num = 1
                             GROUP BY date), t2 as (SELECT time::date as date,
                              count(courier_id) as new_couriers,
                              sum(count(courier_id)) OVER (ORDER BY time::date)::integer as total_couriers
                       FROM   couriers_num
                       WHERE  num = 1
                       GROUP BY date)
SELECT*
FROM   t1
    LEFT JOIN t2 using (date)
