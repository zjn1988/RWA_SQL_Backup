USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_aBondCurve]    Script Date: 2016/2/24 11:13:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得债券收益率曲线>
-- =============================================
CREATE FUNCTION [RWA].[get_aBondCurve]
(	@StartDate DATETIME,
	@EndDate DATETIME, 
	@CurveName varchar(255)
	)
--RETURNS TABLE
RETURNS @Table TABLE
	(
		--CurveName varchar(255),
		term int,
		price decimal(20,15),
		dailyDate date 
	)
AS
begin 
	
	declare @newCurveName varchar(255);
	set @newCurveName=
	(
	select case @CurveName
	when '利率互换-Shibor_3M' then 'CNY IRS - 3M Shibor'
	when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
	when 'FR007' then 'CNY IRS - 7D repo'
	when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'
	else @CurveName
	end 
	);


   insert @Table select * from
(
	-- Add the SELECT statement with parameter references here

	select 
			--curveNameCn CurveName,
			LEFT(curveVertexName,LEN(curveVertexName)-1)*
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
	and LEFT(curveNameCn,LEN(curveNameCn)-3)=@newCurveName
	--and @newCurveName<>'利率互换-Shibor_3M'
	UNION ALL
	select 
			--(case [CurveName] 
			--when 'CNY IRS - 3M Shibor' then '利率互换-Shibor_3M'
			--else [CurveName]
			--end) as 	CurveName
			--CurveName,
			term
			,[InterestRate] price
			, CONVERT(varchar(10), [Balance_Date], 111) dailyDate
	from [Position_DB].[RWA].[InterestRateCurve]
	where [Balance_Date] between @StartDate and @EndDate
	and [CurveName]=@newCurveName


	--select A.[CurveName],B.term,B.price,B.dailyDate from 
	--	(SELECT distinct([CurveName])  [CurveName]
	--		FROM [Position_DB].[RWA].[VarPositionDtlAdj] 
	--		where [Balance_Date] =@BalanceDate 
	--		and (SVaRType = 'Bond' or SVaRType = 'BONDFUTURE')
	--		and [CurveName]<>'利率互换-Shibor_3M'
	--	) as A
	--	left join
	--	(select 
	--		curveNameCn
	--		,LEFT(curveVertexName,LEN(curveVertexName)-1)*
	--		(case right(curveVertexName,1)
	--		when 'D' THEN 1
	--		WHEN 'W' THEN 7
	--		WHEN 'M' THEN 30
	--		WHEN 'Y' THEN 365
	--		END
	--		) as term
	--		,price
	--		, CONVERT(varchar(10), dailyDate, 111) dailyDate
	--		from zx_audit.zx_mkt.v_getBondYield v
	--		where v.dailydate between @StartDate and @EndDate
	--	) as B
	--	ON A.[CurveName]=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)
	--UNION ALL
	--	select A.[CurveName],B.term,B.price,B.dailyDate from 
	--	(SELECT distinct([CurveName]) [CurveName]
	--		FROM [Position_DB].[RWA].[VarPositionDtlAdj] 
	--		where [Balance_Date] =@BalanceDate 
	--		and (SVaRType = 'Bond' or SVaRType = 'BONDFUTURE')
	--		and [CurveName]='利率互换-Shibor_3M'
	--	) as A
	--	left join
	--	(select 
	--		(case [CurveName] 
	--		when 'CNY IRS - 3M Shibor' then '利率互换-Shibor_3M'
	--		else [CurveName]
	--		end) as 	curveNameCn
	--		,[term] term
	--		,[InterestRate] price
	--		, CONVERT(varchar(10), [Balance_Date], 111) dailyDate
	--		from [Position_DB].[RWA].[InterestRateCurve]
	--		where [Balance_Date] between @StartDate and @EndDate
	--	) as B
	--	ON A.[CurveName]=B.curveNameCn
	----and c.balance_date=@BalanceDate
) as A
RETURN

END
--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC








GO
