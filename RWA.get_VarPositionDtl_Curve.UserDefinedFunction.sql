USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_VarPositionDtl_Curve]    Script Date: 2016/2/24 13:11:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_VarPositionDtl_Curve]
(	@StartDate DATETIME,
	@EndDate DATETIME, 
	@BalanceDate DATETIME
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here

	select A.[CurveName],B.term,B.price,B.dailyDate from 
		(SELECT 
			distinct(case ([CurveName]) 
				when  '利率互换-Shibor_3M' then 'CNY IRS - 3M Shibor'
				when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
				when 'FR007' then 'CNY IRS - 7D repo'
				when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'
				ELSE [CurveName]
			end
			) [CurveName]
			FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
			where [Balance_Date] =@BalanceDate 
			and (lower(SVaRType) = 'bond' or lower(SVaRType)  = 'bondfuture' or lower(SVaRType)  = 'irs' )
			--and [CurveName]<>'利率互换-Shibor_3M'
		) as A
		inner join
		(select 
			curveNameCn
			,LEFT(curveVertexName,LEN(curveVertexName)-1)*
			(case right(curveVertexName,1)
			when 'D' THEN 1
			WHEN 'W' THEN 7
			WHEN 'M' THEN 30
			WHEN 'Y' THEN 365
			END
			) as term
			,price
			, CONVERT(varchar(10), dailyDate, 111) dailyDate
			from zx_audit.zx_mkt.v_getBondYield v
			where v.dailydate between @StartDate and @EndDate
		) as B
		ON A.[CurveName]=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)
	UNION ALL
		select A.[CurveName],B.term,B.price,B.dailyDate from 
		(SELECT 
			distinct(case ([CurveName]) 
				when  '利率互换-Shibor_3M' then 'CNY IRS - 3M Shibor'
				when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
				when 'FR007' then 'CNY IRS - 7D repo'
				when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'
				ELSE [CurveName]
			end) [CurveName]
			FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
			where [Balance_Date] =@BalanceDate 
			and (lower(SVaRType) = 'bond' or lower(SVaRType)  = 'bondfuture' or lower(SVaRType)  = 'irs' )
			and [CurveName]='利率互换-Shibor_3M'
		) as A
		inner join
		(select 
			 [CurveName] 	curveNameCn
			,[term] term
			,[InterestRate] price
			, CONVERT(varchar(10), [Balance_Date], 111) dailyDate
			from [Position_DB].[RWA].[InterestRateCurve]
			where [Balance_Date] between @StartDate and @EndDate
		) as B
		ON A.[CurveName]=B.curveNameCn
	--and c.balance_date=@BalanceDate
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC








GO
