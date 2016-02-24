USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_TRS_ContractInfo]    Script Date: 2016/2/24 13:10:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_TRS_ContractInfo]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		结算日,
		业务类型,
		账户类型,
		客户编号,
		--isnull(B.[InternalName] ,'') as 客户名称,
		名义本金,
		持仓市值,
		持仓成本,
		总预付金,
		未付利息_净额,
		已实现未结算盈亏,
		合约价值,
		现金资产,
		现金负债,
		证券资产,
		融券负债,
		总资产,
		总负债--,
		--维持担保比例
	FROM
	(
	select CONVERT(varchar(10), @BalanceDate , 111) as 结算日,
		   'TRS' AS 业务类型,
		   CALC_OBJECT_CODE as 账户类型,
		   CUST_CODE AS 客户编号,
		   ISNULL(sum(NOTIONAL_AMOUNT),0) as 名义本金,
		   ISNULL(sum(TOTAL_HOLD_COST),0) as 持仓成本,
		   ISNULL(sum(MARKET_VALUE),0) as 持仓市值,
		   ISNULL(sum(PAY_AMOUNT_AVA),0) as 总预付金,
		   ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0) as 未付利息_净额,
					--应付利息=未支付利息-预付金利息
		   ISNULL(sum(ACTUAL_PAL_OPEN),0)  as  已实现未结算盈亏,
		   ISNULL(sum(CONTRACT_VALUE),0)  as 合约价值,
		   (
			ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
		   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)
		   ) as 现金资产,
		   (
			ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
		   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
		   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
		   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0)
		   ) as 现金负债,
		   ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0)	as 证券资产,
		   ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0)	as 融券负债,
		   (ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
				+ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)) 
			+ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0) as 总资产,

		   	(ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
			   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
			   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
			   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0))
			+ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0) as 总负债--,
		 --  ((ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
		 --  +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)) 
		 --  +ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0) )/((ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
			--   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
			--   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
			--   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0))
			--+ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0)) as 维持担保比例

	--from Position_DB.qs.TRS_HOLD
	FROM Position_DB.RWA.get_TRS_HOLD_CustCode_Replaced(@BalanceDate)
	where balance_date = @BalanceDate --and (TOTAL_HOLD_COST>1 or TOTAL_HOLD_COST<-1) --and SWAP_STATUS<>2 --and NOTIONAL_AMOUNT<>0
	group by CUST_CODE,CALC_OBJECT_CODE
	) as A
where (名义本金<>0 or 持仓市值<>0 or 持仓成本<>0 or 总预付金<>0 or 未付利息_净额<>0 
		or 已实现未结算盈亏<>0	or 合约价值<>0 or 现金资产<>0 or 现金负债<>0	or 证券资产<>0
		or 融券负债<>0	or 总资产<>0 or 总负债<>0)
)
	--left join
	--[CreditRisk].[Reference].[CounterpartyMapping]  as B
	--on A.客户编号=B.[OuterAlias]
	









GO
