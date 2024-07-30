/* Задача 7.*
Теперь попробуем учесть в наших расчётах затраты с налогами и посчитаем валовую прибыль, то есть ту сумму, которую мы фактически получили в результате реализации 
товаров за рассматриваемый период.

Задание:
Для каждого дня в таблицах orders и courier_actions рассчитайте следующие показатели:

Выручку, полученную в этот день.
Затраты, образовавшиеся в этот день.
Сумму НДС с продажи товаров в этот день.
Валовую прибыль в этот день (выручка за вычетом затрат и НДС).
Суммарную выручку на текущий день.
Суммарные затраты на текущий день.
Суммарный НДС на текущий день.
Суммарную валовую прибыль на текущий день.
Долю валовой прибыли в выручке за этот день (долю п.4 в п.1).
Долю суммарной валовой прибыли в суммарной выручке на текущий день (долю п.8 в п.5).
Колонки с показателями назовите соответственно revenue, costs, tax, gross_profit, total_revenue, total_costs, total_tax, total_gross_profit, gross_profit_ratio, total_gross_profit_ratio

~ Колонку с датами назовите date.
~ Долю валовой прибыли в выручке необходимо выразить в процентах, округлив значения до двух знаков после запятой.
~ Результат должен быть отсортирован по возрастанию даты.
~ Поля в результирующей таблице: date, revenue, costs, tax, gross_profit, total_revenue, total_costs, total_tax, total_gross_profit, gross_profit_ratio, total_gross_profit_ratio
Чтобы посчитать затраты, в этой задаче введём дополнительные условия.
~ В упрощённом виде затраты нашего сервиса будем считать как сумму постоянных и переменных издержек. К постоянным издержкам отнесём аренду складских помещений, 
а к переменным — стоимость сборки и доставки заказа. Таким образом, переменные затраты будут напрямую зависеть от числа заказов.
~ Из данных, которые нам предоставил финансовый отдел, известно, что в августе 2022 года постоянные затраты составляли 120 000 рублей в день. Однако уже в сентябре 
нашему сервису потребовались дополнительные помещения, и поэтому постоянные затраты возросли до 150 000 рублей в день.
~ Также известно, что в августе 2022 года сборка одного заказа обходилась нам в 140 рублей, при этом курьерам мы платили по 150 рублей за один доставленный заказ 
и ещё 400 рублей ежедневно в качестве бонуса, если курьер доставлял не менее 5 заказов в день. В сентябре продакт-менеджерам удалось снизить затраты на сборку 
заказа до 115 рублей, но при этом пришлось повысить бонусную выплату за доставку 5 и более заказов до 500 рублей, чтобы обеспечить более конкурентоспособные 
условия труда. При этом в сентябре выплата курьерам за один доставленный заказ осталась неизменной.

Пояснение: 
При расчёте переменных затрат учитывайте следующие условия:
1. Затраты на сборку учитываются в том же дне, когда был оформлен заказ. Сборка отменённых заказов не производится.
2. Выплата курьерам за доставленный заказ начисляется сразу же после его доставки, поэтому если курьер доставит заказ на следующий день, то и выплата будет учтена в следующем дне.
3. Для получения бонусной выплаты курьерам необходимо доставить не менее 5 заказов в течение одного дня, поэтому если курьер примет 5 заказов в течение дня, но последний из них 
доставит после полуночи, бонусную выплату он не получит.

При расчёте НДС учитывайте, что для некоторых товаров налог составляет 10%, а не 20%. Список товаров со сниженным НДС:
'сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное', 'виноград', 'масло оливковое', 'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
'овсянка', 'макароны', 'баранина', 'апельсины', 'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины'

Также при расчёте величины НДС по каждому товару округляйте значения до двух знаков после запятой.
При расчёте выручки по-прежнему будем считать, что оплата за заказ поступает сразу же после его оформления, т.е. случаи, когда заказ был оформлен в один день, а оплата получена на следующий, возникнуть не могут.
Также помните, что не все заказы были оплачены — некоторые были отменены пользователями.
*/

with 
cost_var_2 as ( SELECT time::date as date, courier_id, action, order_id,
                       case when action = 'deliver_order' then 150 end as cost_delivery,
                       case when date_part('month', time) <= '8' and
                                 date_part('year', time) = '2022' and
                                 action = 'accept_order' then 140
                            when date_part('month', time) >= '9' and
                                 date_part('year', time) = '2022' and
                                 action = 'accept_order' then 115 end as cost_сборка
                FROM   courier_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                ORDER BY courier_id, date), 

cost_var_3 as (SELECT courier_id, date, action,
                      сount(distinct order_id) as count_orders,
                      sum(cost_сборка) as cost_сборка,
                      sum(cost_delivery) as cost_delivery,
                      case when date_part('month', date) <= '8' and
                                date_part('year', date) = '2022' and
                                count(order_id) >= 5 and
                                action = 'deliver_order' then 400
                           when date_part('month', date) >= '9' and
                                date_part('year', date) = '2022' and
                                count(order_id) >= 5 and
                                action = 'deliver_order' then 500
                           else 0 end as bonus_delivery
               FROM   cost_var_2
               GROUP BY courier_id, date, action
               ORDER BY courier_id, date), 
  
cost_var_all as (SELECT date, sum (bonus_delivery) + sum(cost_сборка) + sum(cost_delivery) as all_var_cost,
                        case when date_part('month', date) <= '8' and
                                  date_part('year', date) = '2022' then 120000
                             when date_part('month', date) >= '9' and
                                  date_part('year', date) = '2022' then 150000 end as fix_cost
                 FROM   cost_var_3
                 GROUP BY date
                 ORDER BY date), 
  
products_cte as (SELECT creation_time::date as date, order_id, unnest(product_ids) as product_id
                 FROM   orders
                 WHERE  order_id not in (SELECT order_id
                                         FROM   user_actions
                                         WHERE  action = 'cancel_order')), 
  
products_cte_vat_temp as (SELECT *,  case when products.name in ('сахар', 'сухарики', 'сушки', 'семечки', 'масло льняное',
                                               'виноград', 'масло оливковое', 'арбуз', 'батон',
                                               'йогурт', 'сливки', 'гречка', 'овсянка', 'макароны',
                                               'баранина', 'апельсины', 'бублики', 'хлеб', 'горох',
                                               'сметана', 'рыба копченая', 'мука', 'шпроты', 'сосиски',
                                               'свинина', 'рис', 'масло кунжутное', 'сгущенка',
                                               'ананас', 'говядина', 'соль', 'рыба вяленая', 'масло подсолнечное',
                                               'яблоки', 'груши', 'лепешка', 'молоко', 'курица',
                                               'лаваш', 'вафли', 'мандарины') then 0.10
                                      else 0.20 end as tax
                          FROM   products_cte
                          LEFT JOIN products using(product_id)), 
  
products_cte_vat as (SELECT *, round((price / (1 + products_cte_vat_temp.tax)) * products_cte_vat_temp.tax, 2) as tax_1
                     FROM   products_cte_vat_temp), 
  
basic_metrics_1 as (SELECT date,
                           sum(products_cte_vat.price) as revenue, --выручка
                           all_var_cost + fix_cost as costs,
                           sum(tax_1) as tax
                    FROM   products_cte_vat
                    LEFT JOIN cost_var_all using (date)
                    GROUP BY date, costs
                    ORDER BY date)

SELECT date, revenue, costs, tax,
       revenue - costs - tax as gross_profit,
       sum(revenue) OVER (ORDER BY date) as total_revenue,
       sum(costs) OVER (ORDER BY date) as total_costs,
       sum(tax) OVER (ORDER BY date) as total_tax,
       sum(revenue - costs - tax) OVER (ORDER BY date) as total_gross_profit,
       round(((revenue - costs - tax)*100/revenue), 2) as gross_profit_ratio,
       round((sum(revenue - costs - tax) OVER (ORDER BY date) * 100 / sum(revenue) OVER (ORDER BY date)), 2) as total_gross_profit_ratio
FROM   basic_metrics_1
