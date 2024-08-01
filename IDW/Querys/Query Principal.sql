-- SQL (453153,453155,453158,453159,453162)
-- MySQL (850427, 850495, 850962,851030, 851056, 839151, 865526)

-- Historico
with cte_price as 
(
	SELECT
	PRODUCT_ID,
	DATE AS FechaDesde,
	LEAD(DATE) OVER (PARTITION BY PRODUCT_ID
	ORDER BY DATE) AS FechaHasta,
	PRICE
	FROM sales.sales.prices p 
)
select b.*, p.PRICE
from TDChistorySales.dbo.Billing b 
	inner join cte_price p
		on b.PRODUCT_ID = p.PRODUCT_ID
		AND b.DATE >= p.FechaDesde
		AND (b.DATE < p.FechaHasta OR p.FechaHasta IS NULL)
where b.billing_id in (453153,453155,453158,453159,453162)
		
-- Nuevo	
with cte_price as 
(
	SELECT
	PRODUCT_ID,
	DATE AS FechaDesde,
	LEAD(DATE) OVER (PARTITION BY PRODUCT_ID
	ORDER BY DATE) AS FechaHasta,
	PRICE
	FROM sales.sales.prices p 
)
, cte_billing AS
(
	select b.*, bd.PRODUCT_ID, bd.QUANTITY
	from sales.sales.billing b 
		inner join sales.sales.billing_detail bd 
			on b.BILLING_ID = bd.BILLING_ID
	where b.billing_id in (850427, 850495, 850962,851030, 851056, 839151, 865526)
)
select b.*, p.PRICE
from cte_billing b 
	inner join cte_price p
		on b.PRODUCT_ID = p.PRODUCT_ID
		AND b.DATE >= p.FechaDesde
		AND (b.DATE < p.FechaHasta OR p.FechaHasta IS NULL)
		
--totales con descuentos
with cte_price as 
(
	SELECT
	PRODUCT_ID,
	DATE AS FechaDesde,
	LEAD(DATE) OVER (PARTITION BY PRODUCT_ID
	ORDER BY DATE) AS FechaHasta,
	PRICE
	FROM sales.sales.prices p 
)
, cte_billing AS
(
	select b.BILLING_ID, b.DATE, b.CUSTOMER_ID, b.EMPLOYEE_ID, bd.PRODUCT_ID, bd.QUANTITY, b.REGION
	from sales.sales.billing b 
		inner join sales.sales.billing_detail bd 
			on b.BILLING_ID = bd.BILLING_ID
	where b.BILLING_ID in (850427, 850495, 850962,851030, 851056, 839151, 865526)
	union all 
	select b2.billing_id, b2.date, b2.customer_id, b2.employee_id, b2.product_id, b2.quantity, b2.region
	from TDChistorySales.dbo.Billing b2 
	where b2.BILLING_ID in (453153,453155,453158,453159,453162)
)	
, cte_billing_total AS
(
	select b.billing_id, b.DATE, sum(b.QUANTITY*p.PRICE) as TOTAL_BILLING
	from cte_billing b 
		left join cte_price p
			on b.PRODUCT_ID = p.PRODUCT_ID
			AND b.DATE >= p.FechaDesde
			AND (b.DATE < p.FechaHasta OR p.FechaHasta IS NULL)
	group by b.billing_id, b.DATE
)
select bt.BILLING_ID
	, ISNULL((100-MAX(sd.PERCENTAGE))/100.0, 1) AS PERCENTAGE_Apply
	, ISNULL(MAX(sd.TOTAL_BILLING),0) AS TOTAL_BILLING_Apply
	, bt.TOTAL_BILLING
from cte_billing_total as bt
	left join sales.sales.discounts sd
		on bt.TOTAL_BILLING >= sd.TOTAL_BILLING
		AND bt.DATE >= sd.[FROM]
		AND (bt.DATE < sd.UNTIL OR sd.UNTIL IS NULL)
group by bt.BILLING_ID, bt.TOTAL_BILLING

select *
from sales.sales.discounts