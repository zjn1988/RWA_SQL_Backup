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
-- Description:	<���Լ������ҵ������,����RWA����>
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
		CONVERT(varchar(10), @BalanceDate , 111) as ������,
		'TRS' as ҵ������,
		B.CUST_CODE as �ͻ����,
		(CASE B.[TRADE_MKT_CODE]
		WHEN 'XSHG' THEN B.SEC_CODE+'.SH'
		WHEN 'XSHE' THEN B.SEC_CODE+'.SZ'
		END) AS ֤ȯ����,
		ISNULL(B.[SEC_CODE_NAME],'') AS ֤ȯ����	,	
		sum(B.[CONFIRM_QTY])	AS  ֤ȯ����,
		sum(B.[MARKET_VALUE])	AS  ֤ȯ��ֵ,
		SUM(B.[TOTAL_COST]) AS �ֲֳɱ�
	FROM
	(SELECT * FROM Position_DB.RWA.get_TRS_ContractInfo(@BalanceDate)) AS A,
	Position_DB.RWA.get_TRS_HOLDDTL_CustCode_Replaced(@BalanceDate)  as B	
	WHERE A.�ͻ����=B.CUST_CODE AND B.[CONFIRM_QTY]<>0
	GROUP BY B.CUST_CODE,B.[TRADE_MKT_CODE],B.SEC_CODE,B.[SEC_CODE_NAME]	
)



GO
