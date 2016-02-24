USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_TRS_ContractDtl]    Script Date: 2016/2/24 13:10:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_TRS_ContractDtl]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		CONVERT(varchar(10), @BalanceDate , 111) as 结算日,
		'TRS' as 业务类型,
		B.CUST_CODE as 客户编号,
		(CASE B.[TRADE_MKT_CODE]
		WHEN 'XSHG' THEN B.SEC_CODE+'.SH'
		WHEN 'XSHE' THEN B.SEC_CODE+'.SZ'
		END) AS 证券代码,
		ISNULL(B.[SEC_CODE_NAME],'') AS 证券名称	,	
		sum(B.[CONFIRM_QTY])	AS  证券数量,
		sum(B.[MARKET_VALUE])	AS  证券市值,
		SUM(B.[TOTAL_COST]) AS 持仓成本
	FROM
	(SELECT * FROM Position_DB.RWA.get_TRS_ContractInfo(@BalanceDate)) AS A,
	Position_DB.RWA.get_TRS_HOLDDTL_CustCode_Replaced(@BalanceDate)  as B	
	WHERE A.客户编号=B.CUST_CODE AND B.[CONFIRM_QTY]<>0
	GROUP BY B.CUST_CODE,B.[TRADE_MKT_CODE],B.SEC_CODE,B.[SEC_CODE_NAME]	
)



GO
