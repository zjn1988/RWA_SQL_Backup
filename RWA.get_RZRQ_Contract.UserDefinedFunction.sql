USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RZRQ_Contract]    Script Date: 2016/2/24 11:19:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<��ȯ��ϸ>
-- =============================================
CREATE FUNCTION [RWA].[get_RZRQ_Contract]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	Select CONVERT(varchar(10), @BalanceDate , 111) as ������,
	'��ȯ' AS ҵ������, 
	A.clientid,
	(CASE B.[underlying_mkt]
	WHEN 'XSHE' THEN B.[underlying_id]+'.SZ'
	WHEN 'XSHG' THEN B.[underlying_id]+'.SH'
	END) as ֤ȯ����,
	B.[underlying_amount] ֤ȯ����
	from
	(select clientid
	FROM Position_DB.RWA.get_RZRQ(@BalanceDate)) as A,
	Credit_DB.C_position.acc_balance_contract as B
	WHERE A.clientid=B.clientid
	AND B.[balance_date]=@BalanceDate
	AND B.assettype='RZRQ_1'
	AND ( (B.[underlying_id] IS NOT NULL) AND (B.[underlying_amount] >0 ))
			
)





GO
