/* Задача 2.
Анализируя динамику показателей из предыдущего задания, вы могли заметить, что сравнивать абсолютные значения не очень удобно. Давайте посчитаем динамику показателей в относительных величинах.

Задание:
Дополните запрос из предыдущего задания и теперь для каждого дня, представленного в таблицах user_actions и courier_actions, дополнительно рассчитайте следующие показатели:

Прирост числа новых пользователей.
Прирост числа новых курьеров.
Прирост общего числа пользователей.
Прирост общего числа курьеров.
Показатели, рассчитанные на предыдущем шаге, также включите в результирующую таблицу.

Колонки с новыми показателями назовите соответственно new_users_change, new_couriers_change, total_users_growth, total_couriers_growth. Колонку с датами назовите date.
Все показатели прироста считайте в процентах относительно значений в предыдущий день. При расчёте показателей округляйте значения до двух знаков после запятой.
Результирующая таблица должна быть отсортирована по возрастанию даты.
Поля в результирующей таблице: date, new_users, new_couriers, total_users, total_couriers, new_users_change, new_couriers_change, total_users_growth, total_couriers_growth
*/ 

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
SELECT date,
       new_users,
       total_users,
       new_couriers,
       total_couriers,
       round(((new_users - lag(new_users, 1) OVER (ORDER BY date)::decimal)*100/ lag(new_users, 1) OVER (ORDER BY date)),
             2) as new_users_change,
       round(((new_couriers - lag(new_couriers, 1) OVER (ORDER BY date)::decimal)*100/ lag(new_couriers, 1) OVER (ORDER BY date)),
             2) as new_couriers_change,
       round(((total_users - lag(total_users, 1) OVER (ORDER BY date)::decimal)*100/ lag(total_users, 1) OVER (ORDER BY date)),
             2) as total_users_growth,
       round(((total_couriers - lag(total_couriers, 1) OVER (ORDER BY date)::decimal)*100/ lag(total_couriers, 1) OVER (ORDER BY date)),
             2) as total_couriers_growth
FROM   t1
    LEFT JOIN t2 using (date)
