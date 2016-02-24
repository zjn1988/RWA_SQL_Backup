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
-- Description:	<����г���������,����RWA����>
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
			,case a.Department when '�в�Ͷ��' then '����'else a.Department end +'-'+a.Account as ���
			,(a.YearlyTotalPL-b.YearlyTotalPL)*10000 as PnL

		from
		(
			SELECT balance_date, 
				Department, Account
				,SUM(YearlyTotalPL) AS YearlyTotalPL
			FROM Position_DB.xir.acc_balance_zq2
			WHERE balance_date = @EndDate
				AND Department in ('����', '�ʽ�',  '�в�Ͷ��')
				AND Account <> '����_����'
			GROUP BY balance_date, Department, Account
		)a
		left join
		(
			SELECT balance_date, 
				Department, Account
				,SUM(YearlyTotalPL) AS YearlyTotalPL
			FROM Position_DB.xir.acc_balance_zq2
			WHERE balance_date = @StartDate
				AND Department in ('����', '�ʽ�',  '�в�Ͷ��')
				AND Account <> '����_����'
			GROUP BY balance_date, Department, Account
		)b
		on a.Department=b.Department and a.account=b.account
	)
	union all
	(
		SELECT 
			CONVERT(varchar(10), @StartDate , 111) as StartDate
			,CONVERT(varchar(10), @EndDate , 111) as EndDat
			,���,sum(PnL) as PnL
		from
		(
			select 
					case when category='Ӧ��' then category+'-'+dept
					when dept='����'then dept
					else dept +'-'+ case when category like '%MOM%' then 'MOM' else category end end as ���
				,PnL
			FROM    MarketRisk.Report.fn_market_calculateAccountPnlSeriesQsQuickCNY(@StartDate,@EndDate,'*')
			where category<>'TRS'and accid not in ('JYBJGR','YSP-CWQQ','F_A002','GXETFJ_HKD','GXETFJ_USD')
				AND TradingDate=@EndDate
		)c
		group by ���
	)

)





GO
