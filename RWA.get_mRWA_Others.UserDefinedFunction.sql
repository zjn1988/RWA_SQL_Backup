USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_Others]    Script Date: 2016/2/24 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_Others]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/*

10：现金与货基
20：债券
30：其他股票
40：其他基金
50：商品
41：产品
31：新三板
32：大宗股票（打新、定增）
42：大宗基金
49：调整回模型法
50: 大宗商品

*/



/*  固收部远期与现货对冲 (只算部门层面没有抵消掉的 )  */   

(select c.*, case when secucode like 'SAC%' then 41 else 20 end 标准法类别
--balance_date,accid,secucategory,secucode,quantity,b.Underlying,UnderlyingMarket,CounterpartyName
from
	(
		select distinct underlying 
		from (
			select --,accid,subaccid,组合代码
				distinct underlying,sum(case secucategory when 'bond' then quantity*100 else quantity end) Quantity 
				,balance_date
			from position_db.rwa.mRWA_all 
			where RWA有效性<>1 and accid like '%固收%'
			and balance_date=@BalanceDate
			and underlying not in ('511990','519507','519118','160609','161615','550011','000425','000543','000665')
			--剔除所有货币性基金，此处需要优化到链接基金类别字段			
			group by underlying,balance_date
		)a 
		where quantity>1 or quantity<-1
	)b
	left join	
	(
		select * from position_db.rwa.mRWA_all where RWA有效性<>1 and accid like '%固收%'and balance_date=@BalanceDate
	)c
		on b.underlying=c.underlying 
		


)union all(




/*  标准法（除固收、大宗）分类*/   
select
	*
	,case when SecuCategory ='Cash'or fundtype='货币市场型基金' then 10  --现金或货基
		when SecuCategory ='Bond' then 20   --未上市债券、违约债券等
		when SecuCategory ='Equity' then case when SecuMarket='Neeq' then 31  --新三板
									else case when AccId like '%打新%' or SubAccid='YYB-DX' then 32 --股票打新、定增
											else case when right(secucode,1) not in ('1','2','3','4','5','6','7','8','9','0') 
														or left(secucode,1) not in ('1','2','3','4','5','6','0','8')  then 41  --产品
												 else 30 end 
											end --其他股票
									end
		else case when  SecuCategory in ('ETF','Fund') then 
						case when right(secucode,1) not in ('1','2','3','4','5','6','7','8','9','0') 
								or left(secucode,1) not in ('1','2','3','4','5','6','0','8')  then 41  --产品
						else case when SubAccId='YYB-JJ' then 42  --大宗基金
								when Accid like '%股票交易%' then 49 --调整回标准法计算
								else 40 end --其他基金 
						end end
		end as 标准法类别					

from position_db.rwa.mRWA_all 
where RWA有效性<>1 and accid not like '%固收%' and accid not like '%大宗%' 
and balance_date=@BalanceDate


)union all(


select f.*, 50 标准法类别
from
	(
		select distinct underlying 
		from (
			select distinct underlying,sum(quantity) Quantity,balance_date
			from position_db.rwa.mRWA_all 
			where RWA有效性<>1 and accid like '%大宗%'
			and balance_date=@BalanceDate
			group by underlying,balance_date
		)d 
		where quantity>1 or quantity<-1
	)e
	left join	
	(
		select *
		from position_db.rwa.mRWA_all
		where RWA有效性<>1 and accid like '%大宗%'
			and balance_date=@BalanceDate
	)f
		on e.underlying=f.underlying 


))















GO
