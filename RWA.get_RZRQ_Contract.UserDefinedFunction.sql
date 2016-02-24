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
-- Description:	<融券明细>
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
	Select CONVERT(varchar(10), @BalanceDate , 111) as 结算日,
	'融券' AS 业务类型, 
	A.clientid,
	(CASE B.[underlying_mkt]
	WHEN 'XSHE' THEN B.[underlying_id]+'.SZ'
	WHEN 'XSHG' THEN B.[underlying_id]+'.SH'
	END) as 证券代码,
	B.[underlying_amount] 证券数量
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
