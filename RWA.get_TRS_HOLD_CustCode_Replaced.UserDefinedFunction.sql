USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_TRS_HOLD_CustCode_Replaced]    Script Date: 2016/2/24 13:10:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_TRS_HOLD_CustCode_Replaced]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		case 
		when left(CALC_OBJECT_CODE,9) in ('ZJBJNSWAP','zjbjnswap') then 'ZJBJNSWAP'
		when left(CALC_OBJECT_CODE,9) in ('ZJBJZSWAP','zjbjzswap') then 'ZJBJZSWAP'
		else CALC_OBJECT_CODE
		end as CALC_OBJECT_CODE,
		CALC_OBJECT_ID,
		ISNULL(InternalName,CUST_CODE) AS CUST_CODE,
		CONTRACT_ID,		
		HOLD_DATE,
		NOTIONAL_AMOUNT,
		PAY_AMOUNT,
		COMMISS_INCOME,
		TOTAL_HOLD_COST,
		MARKET_VALUE,
		RT_AMOUNT,
		ACCOUNT_BALANCE,
		TOTAL_INTEREST_INCOME,
		PRE_INTEREST_INCOME,
		NET_INTEREST_INCOME,
		PAY_INTEREST,
		LEFT_INTEREST,
		MARGIN_INTEREST,
		PAL_AMOUNT,
		ACTUAL_PAL_OPEN,
		ACTUAL_PAL_CLOSE,
		ACTUAL_PAL_AMOUNT,
		CONTRACT_VALUE,
		PAL_TOTAL,
		MTM_AMOUNT,
		INIT_AMOUNT,
		MAINTAIN_AMOUNT,
		RISK_AMOUNT,
		SWAP_TYPE,
		SWAP_STATUS,
		PAY_AMOUNT_AVA,
		balance_date,
		import_time,
		audit_ID		 
	FROM
	(SELECT * FROM
	 Position_DB.qs.TRS_HOLD  WHERE balance_date=@BalanceDate) AS A
	 LEFT JOIN
	[CreditRisk].[Reference].[CounterpartyMapping]  as B
	on A.CUST_CODE=B.[OuterAlias]
		
)



GO
