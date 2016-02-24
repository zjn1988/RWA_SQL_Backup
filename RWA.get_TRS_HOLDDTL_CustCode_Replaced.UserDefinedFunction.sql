USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_TRS_HOLDDTL_CustCode_Replaced]    Script Date: 2016/2/24 13:10:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_TRS_HOLDDTL_CustCode_Replaced]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		[CALC_OBJECT_CODE]
      ,[CALC_OBJECT_ID]
      ,ISNULL(InternalName,CUST_CODE) AS CUST_CODE
      ,[CONTRACT_ID]
      ,[HOLD_DATE]
      ,A.[SEC_CODE]
      ,ISNULL([SEC_CODE_NAME],ISNULL(C.curveNameCn,NULL)) as [SEC_CODE_NAME]
      --,CASE 
	  --WHEN  C.curveNameCn IS NULL THEN 'OF'
	  --ELSE A.[TRADE_MKT_CODE]
	  --END AS  [TRADE_MKT_CODE]
	  ,A.[TRADE_MKT_CODE]
      ,[CONFIRM_QTY]
      ,[COST_PRICE]
      ,[CLOSE_PRICE]
      ,[TOTAL_COST]
      ,[TOTAL_PAL]
      ,[TOTAL_FLOAT_PAL]
      ,[MARKET_VALUE]
      ,[BEG_DATE]
      ,[END_DATE]
      ,[SWAP_TYPE]
      ,[balance_date]
      ,[import_time]
      ,[audit_ID]		 
	FROM
	(SELECT * FROM
	 Position_DB.qs.TRS_HOLDDTL  WHERE balance_date=@BalanceDate) AS A
	 LEFT JOIN
	[CreditRisk].[Reference].[CounterpartyMapping]  as B
	on A.CUST_CODE=B.[OuterAlias]
	left join 
	(SELECT 
		distinct LEFT(localcode,6) [SEC_CODE],
		CASE RIGHT(localcode,2) 
		WHEN 'SH' THEN 'XSHG'
		WHEN 'SZ' THEN 'XSHE'
		END TRADE_MKT_CODE,
		curveNamecn 
	FROM
	zx_audit.[ZX_MKT].[getEquityYield](@BalanceDate,@BalanceDate))  as C
	ON A.[SEC_CODE]=C.[SEC_CODE] AND A.[TRADE_MKT_CODE]=C.TRADE_MKT_CODE		
		
)



GO
