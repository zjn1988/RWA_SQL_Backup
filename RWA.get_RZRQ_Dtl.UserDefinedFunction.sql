USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RZRQ_Dtl]    Script Date: 2016/2/24 11:19:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<���Լ������ҵ������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_RZRQ_Dtl]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	Select CONVERT(varchar(10), @BalanceDate , 111) as ������,
	'RZRQ' AS ҵ������, 
	A.clientid,
	֤ȯ����,
	ISNULL(֤ȯ����,0) AS ֤ȯ����,
	ISNULL(֤ȯ��ֵ,0) AS ֤ȯ��ֵ,
	�ʲ�����
	from
	(select clientid
	FROM Position_DB.RWA.get_RZRQ(@BalanceDate)) as A,
	(select
		clientid,
		CASE cltr_mkt
		WHEN 'XSHE' THEN cltr_secid+'.SZ'
		WHEN 'XSHG' THEN cltr_secid+'.SH'
		END as ֤ȯ����,
		sum([cltr_amount]) as ֤ȯ����,
		sum([cltr_value]) as ֤ȯ��ֵ,
		cltr_assettype as �ʲ�����
	 from
	Credit_DB.C_position.acc_balance_collateral	
	where balance_date=@BalanceDate
	and assettype='RZRQ'
	and (cltr_assettype is not null and cltr_assettype <>'CASH' and cltr_assettype <>'CASHFUND' and cltr_assettype <>'WARRANT')
	group by clientid,cltr_mkt,cltr_secid,cltr_assettype
	)	
	as B
	where A.clientid=B.clientid
		
)





GO
