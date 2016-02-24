USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_Amount_Secu]    Script Date: 2016/2/24 11:14:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*�����20151216-1��ʶ�����OF�ͳ��ڻ����Ƿ�����ظ���*/



-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-16,,>
-- Description:	<���ڼ���RWA�ھ��µ�Ͷ�ʹ�ģ>
-- =============================================
CREATE FUNCTION [RWA].[get_Amount_Secu]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


select distinct secucategory+secucode ֤ȯʶ����, ��ϴ��� ��ϴ���,accid,SECUCATEGORY,secucode
	,case when secucategory in ('FwdBond','SWAP') then sum(Notional)
		when secucategory in ('AUFwd') then sum(quantity)*
	(SELECT CLOSE_PRICE FROM position_db.qs.SEC_QUOTATION WHERE balance_date = @balancedate AND SEC_CODE = 'Au99.99') 
	else sum(PresentValue_CNY) end as Ͷ�ʹ�ģ,convert(varchar(10),@balancedate,111) Balance_Date
from Position_DB.rwa.mRWA_all 
where Balance_Date=@BalanceDate 
and secucategory not in ('BondFuture','CommodityFuture','EuiqtyFuture','EquityOption')
group by SECUCATEGORY,secucode,��ϴ���,accid,secucode

union all 

select distinct secucategory+secucode,��ϴ���,accid,secucategory,secucode,presentvalue,convert(varchar(10),@balancedate,111) Balance_Date
from (select distinct subaccid,��ϴ���,accid from Position_DB.rwa.mRWA_all where balance_date=@balancedate )a
left join (select account,secucategory,secucode,presentvalue,ccy from position_db.hld.pureposition where balance_date=@balancedate 
and SECUCATEGORY in ('BondFuture','CommodityFuture','EuiqtyFuture','EquityOption'))b
on subaccid=right(account,len(account)-patindex('%;%',account)) 
where secucategory+secucode is not null

union all

select distinct ҵ������+�ͻ����
	,case �˻����� when 'JYSGH2' then '0303' else '0202'end accid
	,case �˻����� when 'JYSGH2' then '����-����TRS' else '֤��-����TRS'end accid
	,ҵ������,�ͻ����,�ܸ�ծ,convert(varchar(10),@balancedate,111) Balance_Date
from position_db.rwa.get_TRS_ContractInfo(@BalanceDate)

union all

select distinct ҵ������+��Լ����,'0302','����-Լ������',ҵ������,��Լ����,���屾��,convert(varchar(10),@balancedate,111)
from position_db.rwa.get_AGREPO(@BalanceDate)

union all

select distinct ҵ������+clientid,'0201','֤��-������ȯ',ҵ������,clientid,���屾��,convert(varchar(10),@balancedate,111)
from Position_DB.rwa.get_RZRQ(@BalanceDate)

union all

select distinct ҵ������+�ϲ����д���,'0301','����-��Ʊ��Ѻ�ع�',ҵ������,�ϲ����пͻ�,���屾��,convert(varchar(10),@balancedate,111)
from Position_DB.[RWA].[get_CR_STOCKPDG_Cont](@BalanceDate)




)











GO
