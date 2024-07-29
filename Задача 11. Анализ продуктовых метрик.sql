/* Задача 3.*
Дополним наш анализ ещё более интересными расчётами — вычислим все те же метрики, но для каждого дня будем учитывать накопленную выручку и все имеющиеся на текущий момент данные о числе пользователей и заказов. Таким образом, получим динамический ARPU, ARPPU и AOV и сможем проследить, как он менялся на протяжении времени с учётом поступающих нам данных.

Задание:
По таблицам orders и user_actions для каждого дня рассчитайте следующие показатели:

Накопленную выручку на пользователя (Running ARPU).
Накопленную выручку на платящего пользователя (Running ARPPU).
Накопленную выручку с заказа, или средний чек (Running AOV).
Колонки с показателями назовите соответственно running_arpu, running_arppu, running_aov. Колонку с датами назовите date. 

При расчёте всех показателей округляйте значения до двух знаков после запятой. Результат должен быть отсортирован по возрастанию даты. 
Поля в результирующей таблице: date, running_arpu, running_arppu, running_aov */

--на дату вывести
--1.число всех пользователей уникальных
--2.число пользователей, которые совершили заказ и не отменили его
--3.число заказов, которые совершили платящие пользователи
--считаем показатели по платящим пользователям
with 
cost_orders as ( SELECT creation_time::date as date, unnest(product_ids) as product_id, order_id
                 FROM   orders
                 WHERE  order_id not in (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')), 

paying_values as (SELECT date, sum(price) as revenue, count(distinct user_id) as paying_users, count(distinct order_id) as paying_users_orders
                  FROM   cost_orders
                  LEFT JOIN products using (product_id)
                  LEFT JOIN user_actions using (order_id)
                  GROUP BY date
                  ORDER BY date),
  
--теперь считаем отдельно всех пользователей, не исключая отмененные заказы
all_users as ( SELECT time::date as date, count(distinct user_id) as all_users                                   
               FROM   user_actions
               GROUP BY date),
  
--тут считаем уник количество новых пользователей, которые совершили любое действие (не исключая отмененные заказы)
users_num as ( SELECT user_id,  time, row_number() OVER (PARTITION BY user_id ORDER BY time) as num
               FROM   user_actions
               ORDER BY user_id), 

new_users as ( SELECT time::date as date, count(user_id) as new_users
               FROM   users_num
               WHERE  num = 1
               GROUP BY date),
--а тут уже считаем уник количество новых пользователей, которые совершили покупку (ИСКЛлючая отмененные заказы)
paying_users_num as (SELECT user_id, time, row_number() OVER (PARTITION BY user_id ORDER BY time) as num
                     FROM   user_actions
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')
                     ORDER BY user_id), 

paying_new_users as ( SELECT time::date as date, count(user_id) as paying_new_users
                      FROM   paying_users_num
                      WHERE  num = 1
                      GROUP BY date),
--тут мы считаем все показатели накопленным итогом за счет оконок
running_paying_values as ( SELECT date,
                                  sum(revenue) OVER (ORDER BY date) as running_revenue,
                                  sum(new_users) OVER (ORDER BY date) as running_new_users,
                                  sum(paying_new_users) OVER (ORDER BY date) as running_paying_new_users,
                                  sum(paying_users_orders) OVER (ORDER BY date) as running_paying_users_orders
                           FROM   paying_values
                               LEFT JOIN all_users using(date)
                               LEFT JOIN new_users using(date)
                               LEFT JOIN paying_new_users using(date))
--тут считаем метрики на основании подготовленных данных
  
SELECT date,
       round((running_revenue::decimal/running_new_users), 2) as running_arpu,
       round((running_revenue::decimal/running_paying_new_users), 2) as running_arppu,
       round((running_revenue::decimal/running_paying_users_orders), 2) as running_aov
FROM   running_paying_values
