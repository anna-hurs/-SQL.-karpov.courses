/* Задача 7.
Давайте рассчитаем ещё один полезный показатель, характеризующий качество работы курьеров.

Задание:
На основе данных в таблице courier_actions для каждого дня рассчитайте, за сколько минут 
в среднем курьеры доставляли свои заказы.

Колонку с показателем назовите minutes_to_deliver. Колонку с датами назовите date. 
При расчёте среднего времени доставки округляйте количество минут до целых значений. 
Учитывайте только доставленные заказы, отменённые заказы не учитывайте.

Результирующая таблица должна быть отсортирована по возрастанию даты. 
Поля в результирующей таблице: date, minutes_to_deliver */

with timediff_couriers as (SELECT courier_id, order_id, action, time::date as date,
                                  time - lag(time, 1) OVER (PARTITION BY courier_id, order_id ORDER BY time) as time_diff
                           FROM   courier_actions
                           WHERE  order_id not in (SELECT order_id
                                                   FROM   user_actions
                                                   WHERE  action = 'cancel_order'))

SELECT date, avg(extract (epoch FROM time_diff)/60)::integer as minutes_to_deliver
FROM   timediff_couriers
GROUP BY date
ORDER BY date
