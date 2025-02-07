/* Задача 5.*
Немного усложним наш первоначальный запрос и отдельно посчитаем ежедневную выручку с заказов новых пользователей нашего сервиса. Посмотрим, какую долю она составляет в общей выручке с заказов всех пользователей — и новых, и старых.

Задание:
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку, полученную в этот день.
Выручку с заказов новых пользователей, полученную в этот день.
Долю выручки с заказов новых пользователей в общей выручке, полученной за этот день.
Долю выручки с заказов остальных пользователей в общей выручке, полученной за этот день.
Колонки с показателями назовите соответственно revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share. Колонку с датами назовите date. 

Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, new_users_revenue, new_users_revenue_share, old_users_revenue_share */

with 
t1 as ( SELECT creation_time::date as date, order_id, unnest(product_ids) as product_id
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')),
t2 as ( SELECT date, order_id, sum(price) as order_price
        FROM   t1
        LEFT JOIN products using(product_id)
        GROUP BY date, order_id),
  
--вот это все дает нам понимание стоимости каждого заказа
t3 as ( SELECT user_id, min(time::date) as start_date --дата первого действия пользователя как только он начал пользоватеся сервисом
        FROM   user_actions
        GROUP BY user_id), 
  
t4 as ( SELECT user_id, time::date as date, order_id
        FROM   user_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')), 
t5 as (SELECT t3.user_id, t3.start_date, --coalesce(t2.order_id, 0) as order_id 
              t4.order_id
       FROM   t3
       LEFT JOIN t4 ON t3.user_id = t4.user_id and t3.start_date = t4.date
       ORDER BY t3.user_id), 
  
--тут айди заказов новых пользователей в дни совершения своих первых действий
t6 as (SELECT start_date as date, sum(order_price) as new_users_revenue
       FROM   t2
       RIGHT JOIN t5 using(order_id)
       GROUP BY start_date
       ORDER BY start_date)

SELECT date,
       sum(order_price) as revenue, --посчитали общую выручку
       new_users_revenue,
       round((new_users_revenue*100/sum(order_price)), 2) as new_users_revenue_share,
       round((100-(new_users_revenue*100/sum(order_price))), 2) as old_users_revenue_share
FROM   t2
LEFT JOIN t6 using(date)
GROUP BY date, new_users_revenue
