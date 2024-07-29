/* Задача 1.
Начнём с выручки — наиболее общего показателя, который покажет, какой доход приносит наш сервис.

Задание:
Для каждого дня в таблице orders рассчитайте следующие показатели:

Выручку, полученную в этот день.
Суммарную выручку на текущий день.
Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день.
Колонки с показателями назовите соответственно revenue, total_revenue, revenue_change. Колонку с датами назовите date.

Прирост выручки рассчитайте в процентах и округлите значения до двух знаков после запятой.
Результат должен быть отсортирован по возрастанию даты.
Поля в результирующей таблице: date, revenue, total_revenue, revenue_change */

with cost_orders as (SELECT creation_time::date as date,
                            unnest(product_ids) as product_id
                     FROM   orders
                     WHERE  order_id not in (SELECT order_id
                                             FROM   user_actions
                                             WHERE  action = 'cancel_order')), revenue_orders as (SELECT date,
                                                            sum(price) as revenue,
                                                            sum(sum(price)) OVER (ORDER BY date) as total_revenue
                                                     FROM   cost_orders
                                                         LEFT JOIN products using (product_id)
                                                     GROUP BY date
                                                     ORDER BY date)
SELECT date,
       revenue,
       total_revenue,
       round(((revenue - lag(revenue, 1) OVER (ORDER BY date)) *100/ lag(revenue, 1) OVER (ORDER BY date)),
             2) as revenue_change
FROM   revenue_orders
