

select description,*   from dt_inovar_prod_stg.in_aberdeen_dim_purchaseordertype



select distinct purchaseordertype 
 from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorder 

 
 
 
select discounttaken ,paywithdiscount ,* from dt_inovar_prod_stg.in_aberdeen_fact_paymentline 
where discounttaken !=0 and discounttaken is not null


select "date" , id,* from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderreceipt 
where id = '29586'




select apmasterid as aramark , podateentered,pomasterid  as vendor,pooriginaltotal as total  , * from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorder
where pomasterid ='9646'



select  apmasterid as vendor_number ,companyname , podateentered as date_entered
,podatelastreceipt as recvd_date,
pomasterid  as po_no,pooriginaltotal as total  , * from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorder
where pomasterid ='9620'




-----------------------------------------------

select poautoinc,  
	pomasterid,dateentered as date_entered, 
	poqtyreceived as qty_received,
	poqtyreceived as qty_ordered,
	pounitprice as unitprice,
	syuomid,
	qtyuom,
	extendedprice,* from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderline
where pomasterid ='9620'
--where ioid is not null 



select * from dt_inovar_prod_stg.in_aberdeen_fact_payment
where amount = 407.06



--purchaseorderline <> poautoinc
select billedamount, "date", apdate,  *  from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderreceipt
where
purchaseorderline in (
'33151',
'33152',
'33153'
)




select  
	po.apmasterid as vendor_number ,
	po.companyname,
	po.podateentered as date_entered,
	po.podatelastreceipt as recvd_date,
	po.pomasterid  as po_no,
	po.pooriginaltotal as total,
	po_line.poautoinc,  
	po_line.pomasterid,dateentered as date_entered, 
	po_line.poqtyreceived as qty_received,
	po_line.poqtyreceived as qty_ordered,
	po_line.pounitprice as unitprice,
	po_line.syuomid,
	po_line.qtyuom,
	po_line.extendedprice,
	po_order_receipt.billedamount as apbillamount,
	po_order_receipt.apdate as apbilldate
from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorder po 
	join  dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderline po_line
		on po.pomasterid = po_line.pomasterid
	join dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderreceipt po_order_receipt
		on po_order_receipt.purchaseorderline = po_line.poautoinc
where po.pomasterid ='9620'




--------------------------------------------------------


where customer = 'ARAMARK'

where ioid 





select id, quantity , billedquantity , extendedprice , apunitcost, unitcost, stockinguom  , billedamount  , id,apdate  ,* 
from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderreceipt
where id = 9620

29586

select * from dt_inovar_prod_stg.in_aberdeen_dim_purchaseordertype


select discounttaken ,paywithdiscount ,* from dt_inovar_prod_stg.in_aberdeen_fact_paymentline
--where payment = 9646


select * from dt_inovar_prod_stg.in_aberdeen_fact_paymentline 


select * from dt_inovar_prod_stg.in_aberdeen_fact_purchaseorderline 