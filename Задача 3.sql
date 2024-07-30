/* Задача 3.
Теперь предлагаем вам посмотреть на нашу аудиторию немного под другим углом — давайте посчитаем не просто всех пользователей, а именно ту часть, которая оформляет и оплачивает заказы в нашем сервисе. Заодно выясним, какую долю платящие пользователи составляют от их общего числа.

Задание:
Для каждого дня, представленного в таблицах user_actions и courier_actions, рассчитайте следующие показатели:

Число платящих пользователей.
Число активных курьеров.
Долю платящих пользователей в общем числе пользователей на текущий день.
Долю активных курьеров в общем числе курьеров на текущий день.
Колонки с показателями назовите соответственно paying_users, active_couriers, paying_users_share, active_couriers_share. Колонку с датами назовите date. Проследите за тем, чтобы абсолютные показатели были выражены целыми числами. Все показатели долей необходимо выразить в процентах. При их расчёте округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты. 

Поля в результирующей таблице: date, paying_users, active_couriers, paying_users_share, active_couriers_share */

with 
paying_users as (SELECT time::date as date, 
                        count(distinct user_id) filter (WHERE order_id not in (SELECT order_id
                                                                               FROM   user_actions
                                                                               WHERE  action = 'cancel_order')) as paying_users
                 FROM   user_actions
                 GROUP BY date), 

total_users as (SELECT date, sum(count(user_id)) OVER (ORDER BY date)::integer as total_users
                FROM   (SELECT user_id, min(time::date) as date
                        FROM   user_actions
                        GROUP BY user_id) t1
                GROUP BY date), 

active_couriers as (SELECT time::date as date, count(distinct courier_id) as active_couriers
                    FROM   courier_actions
                    WHERE  order_id not in (SELECT order_id
                                            FROM   user_actions
                                            WHERE  action = 'cancel_order')
                    GROUP BY date), 
  
total_couriers as (SELECT date, sum(count(courier_id)) OVER (ORDER BY date)::integer as total_couriers
                   FROM   (SELECT courier_id, min(time::date) as date
                           FROM   courier_actions
                           GROUP BY courier_id) t2
                   GROUP BY date)

SELECT date, paying_users, active_couriers,
       round((paying_users::decimal/total_users*100), 2) as paying_users_share,
       round((active_couriers::decimal/total_couriers*100), 2) as active_couriers_share
FROM   paying_users
LEFT JOIN total_users using (date)
LEFT JOIN active_couriers using (date)
LEFT JOIN total_couriers using (date)
