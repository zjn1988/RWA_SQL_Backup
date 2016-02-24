USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_PnL]    Script Date: 2016/2/24 11:18:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_PnL]
( 

@StartDate DateTime
,@EndDate DateTime 

)

RETURNS TABLE 
AS
RETURN 
(


		(
		select 
			CONVERT(varchar(10), b.balance_date , 111) as StartDate
			,CONVERT(varchar(10), a.balance_date , 111) as EndDate
			,case a.Department when '夹层投资' then '固收'else a.Department end +'-'+a.Account as 组合
			,(a.YearlyTotalPL-b.YearlyTotalPL)*10000 as PnL

		from
		(
			SELECT balance_date, 
				Department, Account
				,SUM(YearlyTotalPL) AS YearlyTotalPL
			FROM Position_DB.xir.acc_balance_zq2
			WHERE balance_date = @EndDate
				AND Department in ('固收', '资金',  '夹层投资')
				AND Account <> '销售_卖方'
			GROUP BY balance_date, Department, Account
		)a
		left join
		(
			SELECT balance_date, 
				Department, Account
				,SUM(YearlyTotalPL) AS YearlyTotalPL
			FROM Position_DB.xir.acc_balance_zq2
			WHERE balance_date = @StartDate
				AND Department in ('固收', '资金',  '夹层投资')
				AND Account <> '销售_卖方'
			GROUP BY balance_date, Department, Account
		)b
		on a.Department=b.Department and a.account=b.account
	)
	union all
	(
		SELECT 
			CONVERT(varchar(10), @StartDate , 111) as StartDate
			,CONVERT(varchar(10), @EndDate , 111) as EndDat
			,组合,sum(PnL) as PnL
		from
		(
			select 
					case when category='应急' then category+'-'+dept
					when dept='大宗'then dept
					else dept +'-'+ case when category like '%MOM%' then 'MOM' else category end end as 组合
				,PnL
			FROM    MarketRisk.Report.fn_market_calculateAccountPnlSeriesQsQuickCNY(@StartDate,@EndDate,'*')
			where category<>'TRS'and accid not in ('JYBJGR','YSP-CWQQ','F_A002','GXETFJ_HKD','GXETFJ_USD')
				AND TradingDate=@EndDate
		)c
		group by 组合
	)

)





GO
