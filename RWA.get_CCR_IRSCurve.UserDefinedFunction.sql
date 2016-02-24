USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRSCurve]    Script Date: 2016/2/24 11:16:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-11-03,,>
-- Description:	<,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRSCurve]
(	
	@BalanceDate DATETIME
	)

RETURNS TABLE 
AS
RETURN 
(

select

	distinct term
	,cast(term as float)/365 as tenor
	,sum(case CurveName when 'CNY IRS - 7D repo' then TDayRate else 0 end) as FR007_Rate
	,sum(case CurveName when 'CNY IRS - ON Shibor' then TDayRate else 0 end) as SHIBORON_Rate 
	,sum(case CurveName when 'CNY IRS - 1Y Deposit' then TDayRate else 0 end) as DEPO_F01Y_Rate
	,sum(case CurveName when 'CNY IRS - 3M Shibor' then TDayRate else 0 end) as SHIBOR_3M_Rate
	,sum(case CurveName when 'CNY IRS - 7D repo' then Volatility else 0 end) as FR007_Vol
	,sum(case CurveName when 'CNY IRS - ON Shibor' then Volatility else 0 end) as SHIBORON_Vol
	,sum(case CurveName when 'CNY IRS - 1Y Deposit' then Volatility else 0 end) as DEPO_F01Y_Vol
	,sum(case CurveName when 'CNY IRS - 3M Shibor' then Volatility else 0 end) as SHIBOR_3M_Vol
 	,@balancedate as BalanceDate

from
(
	select
	@balancedate as BalanceDate,曲线序号
	,a.CurveName
	,a.Term
	,TDayRate
	,Volatility
	from
	(
		select * from (SELECT ROW_NUMBER() OVER( ORDER BY CurveName ) AS 曲线序号,tmp.* FROM( SELECT distinct CurveName,term,InterestRate/100 as TDayRate  
		from [Position_DB].[RWA].[InterestRateCurve]where balance_date=@BalanceDate) tmp )tmp1
	)a
	left join 
	(
		select
			distinct CurveName,term
			,stdev(RateChg)*sqrt(250) as Volatility
		from
		(
			select b.CurveName,b.Term,(TDayRate-[T-1DayRate])as RateChg,TDay
			from
			(
				select CurveName,Term,InterestRate/100 as TDayRate,Balance_date as TDay  
				from [Position_DB].[RWA].[InterestRateCurve]where balance_date between @BalanceDate-365 and @balancedate
			)b
			left join
			(
				select CurveName,Term,InterestRate/100 as 'T-1DayRate',Balance_date as 'T-1Day'
				from [Position_DB].[RWA].[InterestRateCurve]where balance_date between position_db.mkt.pretradingday(@balancedate-365) and position_db.mkt.pretradingday(@balancedate) 
			)c
			on b.CurveName=c.CurveName  and b.Term=c.Term and Position_DB.mkt.pretradingday(TDay)=[T-1Day]
		)bc
		group by CurveName,term
	)bc1
	on a.CurveName=bc1.CurveName and a.term=bc1.term
)abc
group by term

)
GO
