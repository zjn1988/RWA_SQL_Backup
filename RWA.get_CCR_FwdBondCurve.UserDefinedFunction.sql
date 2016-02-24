USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_FwdBondCurve]    Script Date: 2016/2/24 11:15:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<zfb,Name>
-- Create date: <2015-10-14,,>
-- Description:	<获得债券远期业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_FwdBondCurve]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(

/* 债券远期收益率曲线 */

select CONVERT(varchar(10), @BalanceDate ,23) as Balance_Date
,CurveName
,曲线序号
,sum(case when DailyDate=@BalanceDate then [1D_Rate] else 0 end) as [1D_Rate]
,sum(case when DailyDate=@BalanceDate then [1M_Rate] else 0 end) as [1M_Rate]
,sum(case when DailyDate=@BalanceDate then [3M_Rate] else 0 end) as [3M_Rate]
,sum(case when DailyDate=@BalanceDate then [6M_Rate] else 0 end) as [6M_Rate]
,stdev([1D_Chg])*sqrt(249) as '1D_Vol'
,stdev([1M_Chg])*sqrt(249) as '1M_Vol'
,stdev([3M_Chg])*sqrt(249) as '3M_Vol'
,stdev([6M_Chg])*sqrt(249) as '6M_Vol'

 from 

(

select ABCD1.*
, ([ABCD1].[1D_Rate]-[ABCD2].[1D_Rate]) as '1D_Chg'
, ABCD1.[1M_Rate]-ABCD2.[1M_Rate] as '1M_Chg'
, ABCD1.[3M_Rate]-ABCD2.[3M_Rate] as '3M_Chg'
, ABCD1.[6M_Rate]-ABCD2.[6M_Rate] as '6M_Chg'


from
(
	select ABC.DailyDate,ABC.CurveName,[1D_Rate],[1M_Rate],[3M_Rate],[6M_Rate],曲线序号,日期序号
	from 
	(
		select DailyDate,AB.CurveName,[1D_Rate],[1M_Rate],[3M_Rate],[6M_Rate],C.曲线序号

		from
		( 
			select DailyDate
			,CurveName
			,sum(case when CurveVertexName='1D' then Rate else 0 end) as '1D_Rate'
			,sum(case when CurveVertexName='1M' then Rate else 0 end) as '1M_Rate'
			,sum(case when CurveVertexName='3M' then Rate else 0 end) as '3M_Rate'
			,sum(case when CurveVertexName='6M' then Rate else 0 end) as '6M_Rate'  
			from
			(
				SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
				and Secucategory='FwdBond'and RWA有效性=1 and CounterpartyName is not null
			) as A
			left join
			(
				select curveNameCn,curveVertexName,price/100 as Rate, CONVERT(varchar(10), dailyDate, 111) dailyDate
				from zx_audit.zx_mkt.v_getBondYield v1
				where (v1.dailydate between dateadd(year,-1,@BalanceDate) and @BalanceDate)
				and (CurveVertexName='1D'or CurveVertexName='1m'
					or CurveVertexName='3m'	or CurveVertexName='6m')
					 --between @StartDate and @BalanceDate
			) as B 
			ON A.CurveName=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)
			group by DailyDate,CurveName
		)as AB
		left join 
		(
			select * from (SELECT ROW_NUMBER() OVER( ORDER BY CurveName ) AS 曲线序号,f.* 
			FROM( SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
				and Secucategory='FwdBond'and RWA有效性=1 and CounterpartyName is not null  ) f )tmp1
		)as C
		on AB.CurveName=C.CurveName
		) as ABC
	left join 
	(
			select * from (SELECT ROW_NUMBER() OVER( ORDER BY dailydate) AS 日期序号,e.* 
			FROM( select distinct dailydate from zx_audit.zx_mkt.v_getBondYield v2
				where (v2.dailydate between dateadd(year,-1,@BalanceDate) and @BalanceDate) ) e )tmp2	
	)as D
	on ABC.dailyDate=D.dailyDate
	where (ABC.dailydate is not null) 
)as ABCD1
left join 
(
	select ABC.DailyDate,ABC.CurveName,[1D_Rate],[1M_Rate],[3M_Rate],[6M_Rate],曲线序号,日期序号
	from 
	(
		select DailyDate,AB.CurveName,[1D_Rate],[1M_Rate],[3M_Rate],[6M_Rate],C.曲线序号

		from
		( 
			select DailyDate
			,CurveName
			,sum(case when CurveVertexName='1D' then Rate else 0 end) as '1D_Rate'
			,sum(case when CurveVertexName='1M' then Rate else 0 end) as '1M_Rate'
			,sum(case when CurveVertexName='3M' then Rate else 0 end) as '3M_Rate'
			,sum(case when CurveVertexName='6M' then Rate else 0 end) as '6M_Rate'  
			from
			(
				SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
				and Secucategory='FwdBond'and RWA有效性=1 and CounterpartyName is not null
			) as A
			left join
			(
				select curveNameCn,curveVertexName,price/100 as Rate, CONVERT(varchar(10), dailyDate, 111) dailyDate
				from zx_audit.zx_mkt.v_getBondYield v1
				where (v1.dailydate between dateadd(day,-1,dateadd(year,-1,@BalanceDate)) and dateadd(day,-1,@BalanceDate))
				and (CurveVertexName='1D'or CurveVertexName='1m'
					or CurveVertexName='3m'	or CurveVertexName='6m')
					 --between @StartDate and @BalanceDate
			) as B 
			ON A.CurveName=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)
			group by DailyDate,CurveName
		)as AB
		left join 
		(
			select * from (SELECT ROW_NUMBER() OVER( ORDER BY CurveName ) AS 曲线序号,f.* 
			FROM( SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
				and Secucategory='FwdBond'and RWA有效性=1 and CounterpartyName is not null ) f )tmp1
		)as C
		on AB.CurveName=C.CurveName
		) as ABC
	left join 
	(
			select * from (SELECT ROW_NUMBER() OVER( ORDER BY dailydate) AS 日期序号,e.* 
			FROM( select distinct dailydate from zx_audit.zx_mkt.v_getBondYield v2
				where (v2.dailydate between mkt.pretradingday(dateadd(year,-1,@BalanceDate)) and mkt.pretradingday(@BalanceDate)) ) e )tmp2	
	)as D
	on ABC.dailyDate=D.dailyDate
	where (ABC.dailydate is not null) 
)as ABCD2
on ABCD1.日期序号=ABCD2.日期序号 and ABCD1.曲线序号=ABCD2.曲线序号
--order by ABCD1.曲线序号,ABCD1.DailyDate,ABCD1.日期序号
) as data
group by 曲线序号,CurveName


)





GO
