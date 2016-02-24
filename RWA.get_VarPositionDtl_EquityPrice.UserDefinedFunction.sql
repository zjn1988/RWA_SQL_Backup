USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_VarPositionDtl_EquityPrice]    Script Date: 2016/2/24 13:11:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_VarPositionDtl_EquityPrice]
(	@StartDate DATETIME,
	@EndDate DATETIME, 
	@BalanceDate DATETIME
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here

	select A.RiskFactor ID, B.obsPrice Price,B.dailyDate from
	(
	select localcode,curveNamecn,obsPrice,CONVERT(varchar(10), dailyDate, 111) dailyDate 
	from zx_audit.[ZX_MKT].[getEquityYield](@StartDate,@EndDate) 
	--order by localCode,dailyDate 
	) AS B
	,
	(
		SELECT 
		distinct(RiskFactor)  RiskFactor				
		FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
		where [Balance_Date] =@BalanceDate 
		and (
			lower(SVaRType) = lower('Equity' ) 
			or lower(SVaRType) = lower('CVBond') 
			or lower(SVaRType) = lower('fund') 
			)
	) as A
	where LOWER(B.localcode)=LOWER(A.RiskFactor)

	UNION ALL

	select A.RiskFactor ID, B.Price,B.dailyDate from
		(
			SELECT
				code localcode,
				--name,
				price Price,
				CONVERT(varchar(10), dailyDate, 111) dailydate
			FROM ZX_AUDIT.zx_mkt.v_getOFPrice
			WHERE dailyDate between @StartDate and @EndDate
			--and code='160224'
		--order by localCode,dailyDate 
		) AS B
	right join 
	(
		select  RiskFactor  from
		(
			select A.RiskFactor RiskFactor, B.localcode localcode  from
			(
			select distinct(localcode)
			from zx_audit.[ZX_MKT].[getEquityYield](@StartDate,@EndDate) 
			--order by localCode,dailyDate 
			) AS B
			right join 
			(
				SELECT 
				distinct(RiskFactor)  RiskFactor				
				FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
				where [Balance_Date] =@BalanceDate 
				and (
					lower(SVaRType) = lower('Equity' ) 
					or lower(SVaRType) = lower('CVBond') 
					or lower(SVaRType) = lower('fund') 
					)
			) as A
			ON LOWER(B.localcode)=LOWER(A.RiskFactor)
		) as C
		where C.localcode is null
	) as A
	ON LOWER(B.localcode)=LOWER(left(A.RiskFactor,6))

	--order by B.localCode,B.dailyDate 
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC








GO
