USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_VarPositionDtl_IrsCurve]    Script Date: 2016/2/24 13:11:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_VarPositionDtl_IrsCurve]
(	@StartDate DATETIME,
	@EndDate DATETIME, 
	@BalanceDate DATETIME
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here

	select A.[RiskFactor],B.price,B.dailyDate from 
		(SELECT distinct([RiskFactor])  [RiskFactor]
			FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
			where [Balance_Date] =@BalanceDate 
			and lower(SVaRType) = 'irs'
		) as A
		left join
		(select 
			(case [CurveName]
			when 'CNY IRS - 3M Shibor' then 'SHIBOR-3M'
			when 'CNY IRS - ON Shibor' then 'CNY IRS - ON Shibor'--可能需要映射
			when 'CNY IRS - 7D repo' then 'FR007'
			when 'CNY IRS - 1Y Deposit' then 'DEPO_F01Y'
			end)
			+'.'+
			(
			case [term]
				when 1 then '1d'
				when 7 then '1w'
				when 14 then '2w'
				when 30 then '1m'
				when 60 then '2m'
				when 91 then '3m'
				when 182 then '6m'
				when 273 then '9m'
				when 365 then '1y'
				when 730 then '2y'
				when 1095 then '3y'
				when 1460 then '4y'
				when 1825 then '5y'
				when 2190 then '6y'
				when 2555 then '7y'
				when 2920 then '8y'
				when 3285 then '9y'
				when 3650 then '10y'
			end
			) as curveNameCn
			,[InterestRate]  price
			, CONVERT(varchar(10), [Balance_Date], 111) dailyDate
			from [Position_DB].[RWA].[InterestRateCurve] v
			where [Balance_Date] between @StartDate and @EndDate
		) as B
		ON LOWER(A.[RiskFactor])=LOWER(B.curveNameCn)
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC








GO
