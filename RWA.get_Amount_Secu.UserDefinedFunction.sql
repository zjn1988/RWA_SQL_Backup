USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_Amount_Secu]    Script Date: 2016/2/24 11:14:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*待解决20151216-1：识别码对OF和场内基金是否会有重复？*/



-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-16,,>
-- Description:	<用于计算RWA口径下的投资规模>
-- =============================================
CREATE FUNCTION [RWA].[get_Amount_Secu]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


select distinct secucategory+secucode 证券识别码, 组合代码 组合代码,accid,SECUCATEGORY,secucode
	,case when secucategory in ('FwdBond','SWAP') then sum(Notional)
		when secucategory in ('AUFwd') then sum(quantity)*
	(SELECT CLOSE_PRICE FROM position_db.qs.SEC_QUOTATION WHERE balance_date = @balancedate AND SEC_CODE = 'Au99.99') 
	else sum(PresentValue_CNY) end as 投资规模,convert(varchar(10),@balancedate,111) Balance_Date
from Position_DB.rwa.mRWA_all 
where Balance_Date=@BalanceDate 
and secucategory not in ('BondFuture','CommodityFuture','EuiqtyFuture','EquityOption')
group by SECUCATEGORY,secucode,组合代码,accid,secucode

union all 

select distinct secucategory+secucode,组合代码,accid,secucategory,secucode,presentvalue,convert(varchar(10),@balancedate,111) Balance_Date
from (select distinct subaccid,组合代码,accid from Position_DB.rwa.mRWA_all where balance_date=@balancedate )a
left join (select account,secucategory,secucode,presentvalue,ccy from position_db.hld.pureposition where balance_date=@balancedate 
and SECUCATEGORY in ('BondFuture','CommodityFuture','EuiqtyFuture','EquityOption'))b
on subaccid=right(account,len(account)-patindex('%;%',account)) 
where secucategory+secucode is not null

union all

select distinct 业务类型+客户编号
	,case 账户类型 when 'JYSGH2' then '0303' else '0202'end accid
	,case 账户类型 when 'JYSGH2' then '股衍-境内TRS' else '证金-境内TRS'end accid
	,业务类型,客户编号,总负债,convert(varchar(10),@balancedate,111) Balance_Date
from position_db.rwa.get_TRS_ContractInfo(@BalanceDate)

union all

select distinct 业务类型+合约代码,'0302','股衍-约定购回',业务类型,合约代码,名义本金,convert(varchar(10),@balancedate,111)
from position_db.rwa.get_AGREPO(@BalanceDate)

union all

select distinct 业务类型+clientid,'0201','证金-融资融券',业务类型,clientid,名义本金,convert(varchar(10),@balancedate,111)
from Position_DB.rwa.get_RZRQ(@BalanceDate)

union all

select distinct 业务类型+合并盯市代码,'0301','股衍-股票质押回购',业务类型,合并盯市客户,名义本金,convert(varchar(10),@balancedate,111)
from Position_DB.[RWA].[get_CR_STOCKPDG_Cont](@BalanceDate)




)











GO
