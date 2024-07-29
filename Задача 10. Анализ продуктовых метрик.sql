/* Задача 2.
Теперь на основе данных о выручке рассчитаем несколько относительных показателей, которые покажут, сколько в среднем потребители готовы платить за услуги нашего сервиса доставки. Остановимся на следующих метриках:
1. ARPU (Average Revenue Per User) — средняя выручка на одного пользователя за определённый период.
2. ARPPU (Average Revenue Per Paying User) — средняя выручка на одного платящего пользователя за определённый период.
3. AOV (Average Order Value) — средний чек, или отношение выручки за определённый период к общему количеству заказов за это же время.

Если за рассматриваемый период сервис заработал 100 000 рублей и при этом им пользовались 500 уникальных пользователей, из которых 400 сделали в общей сложности 650 заказов, тогда метрики будут иметь следующие значения:
ARPU =100000/500=200     ARPPU =100000/400=250      AOV=100000/650≈153,85

Задание:
Для каждого дня в таблицах orders и user_actions рассчитайте следующие показатели:

Выручку на пользователя (ARPU) за текущий день.
Выручку на платящего пользователя (ARPPU) за текущий день.
Выручку с заказа, или средний чек (AOV) за текущий день.
Колонки с показателями назовите соответственно arpu, arppu, aov. Колонку с датами назовите date. 

При расчёте всех показателей округляйте значения до двух знаков после запятой. Результат должен быть отсортирован по возрастанию даты. Поля в результирующей таблице: date, arpu, arppu, aov */

--на дату вывести
--1.число всех пользователей уникальных
--2.число пользователей, которые совершили заказ и не отменили его
--3.число заказов, которые совершили платящие пользователи 
with cost_orders as (SELECT creation_time::date as date,
                            unnest(product_ids) as product_id,
                            order_id
                     FROM   orders
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')), paying_values as (SELECT date, sum(price) as revenue,
                                                                                                       count(distinct user_id) as paying_users,
                                                                                                       count(distinct order_id) as paying_users_orders
                                                                                                 FROM cost_orders
                                                                      LEFT JOIN products using (product_id)
                                                                      LEFT JOIN user_actions using (order_id)
                                                                  GROUP BY date
                                                                  ORDER BY date), all_users as (SELECT time::date as date,
                                                   count(distinct user_id) as all_users
                                            FROM   user_actions
                                            GROUP BY date)

SELECT date,
       round((revenue::decimal/all_users), 2) as arpu,
       round((revenue::decimal/paying_users), 2) as arppu,
       round((revenue::decimal/paying_users_orders), 2) as aov
FROM   paying_values
    LEFT JOIN all_users using(date)
