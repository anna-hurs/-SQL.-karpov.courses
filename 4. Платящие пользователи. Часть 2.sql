/* Задача 4.
Давайте подробнее остановимся на платящих пользователях, копнём немного глубже и выясним, 
как много платящих пользователей совершают более одного заказа в день. В конце концов нам 
важно понимать, как в большинстве своём ведут себя наши пользователи — они заходят в приложение,
чтобы сделать всего один заказ, или же наш сервис настолько хорош, что они готовы пользоваться 
им несколько раз в день.

Задание:
Для каждого дня, представленного в таблице user_actions, рассчитайте следующие показатели:

Долю пользователей, сделавших в этот день всего один заказ, в общем количестве платящих пользователей.
Долю пользователей, сделавших в этот день несколько заказов, в общем количестве платящих пользователей.
Колонки с показателями назовите соответственно single_order_users_share, several_orders_users_share. 
Колонку с датами назовите date. Все показатели с долями необходимо выразить в процентах. 
При расчёте долей округляйте значения до двух знаков после запятой.

Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, single_order_users_share, several_orders_users_share */

with 
paying_users as (SELECT time::date as date, user_id, count(order_id) as num,
                        case when count(order_id) = 1 then 'single'
                             when count(order_id) > 1 then 'several' end as type1
                 FROM   user_actions
                 WHERE  order_id not in (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')
                 GROUP BY date, user_id), 
  
type_table as (SELECT date,
                      count(type1) filter (WHERE type1 = 'single') as single,
                      count(type1) filter (WHERE type1 = 'several') as several
               FROM   paying_users
               GROUP BY date, type1
               ORDER BY date), 
  
total_paying as (SELECT time::date as date,
                        count(distinct user_id) filter (WHERE order_id not in (SELECT order_id
                                                                               FROM   user_actions
                                                                               WHERE  action = 'cancel_order')) as paying_users
                 FROM   user_actions
                 GROUP BY date), 
  
all_actions as (SELECT * FROM type_table LEFT JOIN total_paying using(date))

SELECT date,
       round((max(single::decimal/paying_users*100)), 2) as single_order_users_share,
       round((max(several::decimal/paying_users*100)), 2) as several_orders_users_share
FROM   all_actions
GROUP BY date, paying_users
ORDER BY date
