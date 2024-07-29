/* Задача 6.
Теперь давайте попробуем примерно оценить нагрузку на наших курьеров и узнаем, сколько в среднем заказов и пользователей приходится на каждого из них.

Задание:
На основе данных в таблицах user_actions, courier_actions и orders для каждого дня рассчитайте следующие показатели:

Число платящих пользователей на одного активного курьера.
Число заказов на одного активного курьера.
Колонки с показателями назовите соответственно users_per_courier и orders_per_courier. Колонку с датами назовите date. 
При расчёте показателей округляйте значения до двух знаков после запятой.

Результирующая таблица должна быть отсортирована по возрастанию даты. Поля в результирующей таблице: date, users_per_courier, orders_per_courier */

with paying_users_count_orders as (SELECT time::date as date,
                                          count(distinct user_id) as paying_users,
                                          count(distinct order_id) as orders
                                   FROM   user_actions
                                   WHERE  order_id not in (SELECT order_id
                                                           FROM   user_actions
                                                           WHERE  action = 'cancel_order')
                                   GROUP BY date), active_couriers as (SELECT time::date as date,
                                           count(distinct courier_id) as active_couriers
                                    FROM   courier_actions
                                    WHERE  order_id not in (SELECT order_id
                                                            FROM   user_actions
                                                            WHERE  action = 'cancel_order')
                                    GROUP BY date)
SELECT date,
       round((paying_users*1/active_couriers::decimal), 2) as users_per_courier,
       round((orders*1/active_couriers::decimal), 2) as orders_per_courier
FROM   paying_users_count_orders
    LEFT JOIN active_couriers using (date)
