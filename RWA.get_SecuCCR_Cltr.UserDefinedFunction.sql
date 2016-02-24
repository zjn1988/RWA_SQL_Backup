USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_Cltr]    Script Date: 2016/2/24 13:09:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-09,,>
-- Description:	<>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_Cltr]
( 
	@BalanceDate DATE

	)

RETURNS TABLE 
AS
RETURN 
(

--declare @balancedate datetime
--set @balancedate='2015-11-30'

select @BalanceDate Balance_Date
	,业务类型
	,业务类型+客户编号 as 净额结算识别码
	,b.证券代码
	,证券类型
	,证券市值
	,上市日期

	,case 
		when b.证券类型 in('Bond','CVBONDS') then 10
		when b.证券类型 ='FUND' then 
			case when cast(日均成交量 as numeric(18,4))=0 then 60 
				else case when 证券数量/cast(日均成交量 as numeric(18,4))/0.2*1<10 then 10
						when  证券数量/cast(日均成交量 as numeric(18,4))/0.2*1>60 then 60
					else 证券数量/日均成交量/0.2*1 end end 
		when b.证券类型='STOCK' then 
			case when cast(收盘价 as numeric(18,4))=0 or cast(日均成交量 as numeric(18,4))=0 then 60 
				else case when 解禁日期 is null or datediff(day,@balancedate,解禁日期)<0 then case when 证券市值/收盘价/日均成交量/0.2*1<10 then 10
																								  when 证券市值/收盘价/日均成交量/0.2*1>60 then 60
																								  else 证券市值/收盘价/日均成交量/0.2*1 end
						else case when (证券市值/收盘价/日均成交量/0.2*1+datediff(day,@balancedate,解禁日期))<10 then 10 
						    when (证券市值/收盘价/日均成交量/0.2*1+datediff(day,@balancedate,解禁日期))>60 then 60 
							else (证券市值/收盘价/日均成交量/0.2*1+datediff(day,@balancedate,解禁日期)) end end end 
		when b.证券类型='INDEX' then 10
		else 60 end as 流动性期限
	
	,case when 证券市值>0 then 证券市值*定性折算比例 else 0 end as 定性扣减
	,case when 证券市值>0 then 证券市值*最大折扣 else 0 end as 扣减上限
	,case when 证券市值>0 then 证券市值*最小折扣 else 0 end as 扣减下限

  

from
(			
		select 客户编号,业务类型,case when 证券代码 is null then '000300.SH' else 证券代码 end as 证券代码
			,sum(证券数量) as 证券数量,sum(证券市值) as 证券市值 
		from position_db.rwa.get_TRS_ContractDtl(@balancedate) group by 业务类型,客户编号,证券代码
	union all 
		select clientid,业务类型,证券代码,sum(证券数量),sum(证券市值) 
		from position_db.rwa.get_RZRQ_Dtl(@balancedate) group by 业务类型,clientid,证券代码
	union all 
		select distinct 合并盯市代码,'STOCKPDG' 业务类型,抵押券代码,sum(抵押券数量),sum(抵押券市值) 
		from position_db.rwa.get_CR_STOCKPDG_Cltr(@balancedate)v  group by 合并盯市代码,抵押券代码
	union all 
		select 合约代码,业务类型,抵押券代码,sum(抵押券数量),sum(抵押权市值) 
		from position_db.rwa.get_AGREPO(@balancedate) group by 合约代码,业务类型,抵押券代码	
)a	
left join
(
	select 证券代码,证券类型,上市日期,日均成交量,收盘价,定性折算比例,最大折扣,最小折扣,代码
	from position_db.rwa.SecuCCR_SecuAdj where Balance_Date=@Balancedate
)b	
	on a.证券代码=b.证券代码 or (right(b.证券代码,2)='OF'and left(a.证券代码,6)=b.代码)
left join 
(
	SELECT trade_id,RELIEVE_DATE 解禁日期 FROM EDM_BASE.BF_ZX_RPM.VSRP_TRADE_INFO WHERE upddate_time=@balancedate
)c	
	on a.客户编号=c.trade_id
	


)









GO
