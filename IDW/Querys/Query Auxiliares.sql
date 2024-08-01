with cte_precios as(
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
	inner join cte_precios p
		on b.product_id  = p.product_id
		and b.[date] >= p.FechaDesde
		and (b.[date] < p.FechaHasta
			or
			p.FechaHasta is null
		)
where billing_id in (453153,453155,453158,453159,453162)


select *
from TDChistorySales.dbo.Billing b 
where billing_id in (453153,453155,453158,453159,453162)

select * from 



SELECT
	PRODUCT_ID,
	DATE AS FechaDesde,
	LEAD(DATE) OVER (PARTITION BY PRODUCT_ID
	ORDER BY DATE) AS FechaHasta,
	PRICE
	FROM sales.sales.prices p 
where PRODUCT_ID in (1,2,13,35,37)	

select *
from sales.sales.prices p 
where PRODUCT_ID in (1,2,13,35,37)

select top 10 *
from sales.sales.discounts d 