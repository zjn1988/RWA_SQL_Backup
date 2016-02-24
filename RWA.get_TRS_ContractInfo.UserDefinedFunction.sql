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
-- Description:	<���Լ������ҵ������,����RWA����>
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
		������,
		ҵ������,
		�˻�����,
		�ͻ����,
		--isnull(B.[InternalName] ,'') as �ͻ�����,
		���屾��,
		�ֲ���ֵ,
		�ֲֳɱ�,
		��Ԥ����,
		δ����Ϣ_����,
		��ʵ��δ����ӯ��,
		��Լ��ֵ,
		�ֽ��ʲ�,
		�ֽ�ծ,
		֤ȯ�ʲ�,
		��ȯ��ծ,
		���ʲ�,
		�ܸ�ծ--,
		--ά�ֵ�������
	FROM
	(
	select CONVERT(varchar(10), @BalanceDate , 111) as ������,
		   'TRS' AS ҵ������,
		   CALC_OBJECT_CODE as �˻�����,
		   CUST_CODE AS �ͻ����,
		   ISNULL(sum(NOTIONAL_AMOUNT),0) as ���屾��,
		   ISNULL(sum(TOTAL_HOLD_COST),0) as �ֲֳɱ�,
		   ISNULL(sum(MARKET_VALUE),0) as �ֲ���ֵ,
		   ISNULL(sum(PAY_AMOUNT_AVA),0) as ��Ԥ����,
		   ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0) as δ����Ϣ_����,
					--Ӧ����Ϣ=δ֧����Ϣ-Ԥ������Ϣ
		   ISNULL(sum(ACTUAL_PAL_OPEN),0)  as  ��ʵ��δ����ӯ��,
		   ISNULL(sum(CONTRACT_VALUE),0)  as ��Լ��ֵ,
		   (
			ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
		   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)
		   ) as �ֽ��ʲ�,
		   (
			ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
		   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
		   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
		   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0)
		   ) as �ֽ�ծ,
		   ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0)	as ֤ȯ�ʲ�,
		   ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0)	as ��ȯ��ծ,
		   (ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
				+ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)) 
			+ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0) as ���ʲ�,

		   	(ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
			   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
			   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
			   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0))
			+ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0) as �ܸ�ծ--,
		 --  ((ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA>=0 THEN PAY_AMOUNT_AVA END),0)
		 --  +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN>=0 THEN ACTUAL_PAL_OPEN END),0)) 
		 --  +ISNULL(SUM(CASE WHEN MARKET_VALUE>=0 THEN MARKET_VALUE END),0) )/((ISNULL(SUM(CASE WHEN PAY_AMOUNT_AVA<0 THEN 0-PAY_AMOUNT_AVA END),0)
			--   +ISNULL(SUM(CASE WHEN ACTUAL_PAL_OPEN<0 THEN 0-ACTUAL_PAL_OPEN END),0)
			--   +ISNULL(SUM(CASE WHEN TOTAL_HOLD_COST>0 THEN TOTAL_HOLD_COST END),0)
			--   +ISNULL(sum(LEFT_INTEREST-MARGIN_INTEREST),0))
			--+ISNULL(SUM(CASE WHEN MARKET_VALUE<0 THEN 0-MARKET_VALUE END),0)) as ά�ֵ�������

	--from Position_DB.qs.TRS_HOLD
	FROM Position_DB.RWA.get_TRS_HOLD_CustCode_Replaced(@BalanceDate)
	where balance_date = @BalanceDate --and (TOTAL_HOLD_COST>1 or TOTAL_HOLD_COST<-1) --and SWAP_STATUS<>2 --and NOTIONAL_AMOUNT<>0
	group by CUST_CODE,CALC_OBJECT_CODE
	) as A
where (���屾��<>0 or �ֲ���ֵ<>0 or �ֲֳɱ�<>0 or ��Ԥ����<>0 or δ����Ϣ_����<>0 
		or ��ʵ��δ����ӯ��<>0	or ��Լ��ֵ<>0 or �ֽ��ʲ�<>0 or �ֽ�ծ<>0	or ֤ȯ�ʲ�<>0
		or ��ȯ��ծ<>0	or ���ʲ�<>0 or �ܸ�ծ<>0)
)
	--left join
	--[CreditRisk].[Reference].[CounterpartyMapping]  as B
	--on A.�ͻ����=B.[OuterAlias]
	









GO
