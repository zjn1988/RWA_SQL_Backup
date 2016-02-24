USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RWA2015]    Script Date: 2016/2/24 11:18:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
--请修改存储过程!!!!!!!!!
-- =============================================
CREATE FUNCTION [RWA].[get_RWA2015]
( 
@StartDate datetime,
@BalanceDate DateTime 

)

RETURNS TABLE 
AS
RETURN 
(

	select 

		convert(varchar(10),@BalanceDate,111) as Balance_Date
		,cast(组合代码 as varchar(4)) as 组合代码,组合,总规模,净规模,SVaR,IRC
		,SVaR*1.6*12.5 GeneralmRWA
		,IRC*12.5 SpecificmRWA
		,SVaR*1.6+IRC MktRWA
		,CreditRWA
		,StdRWA
		,SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA as TotalRWA
		,扣除调配资金使用费收益
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			扣除调配资金使用费收益/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		 as RoRWA
		,VaR有效性
		,IRC有效性
		,CCR有效性
		,PnL 参考PnL
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			PnL/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		  as 参考RoRWA

	from(
		select 
			abd.组合代码,abd.Accid 组合,总规模,净规模
			,0 as SVaR
			,0 as IRC
			,0 as CreditRWA
			,0 as StdRWA
			,PnL
			,0 as 扣除调配资金使用费收益
			,VaR有效性
			,IRC有效性
			,0 as CCR有效性  --待完善

		from(select 
				ab.*,case when  d.组合 is null then 0 else 1 end IRC有效性
			 from(select 
			         a.*	,case when b.组合 is null then 0 else 1 end VaR有效性 
				  from position_db.rwa.get_amount_account(@BalanceDate) as a 
				  left join(select distinct 组合  
							from position_db.rwa.VarPositionDtl_v2 
							where  balance_date=@BalanceDate	
							)b 
				  on a.组合代码=b.组合
				)ab 
				left join 
				(select distinct 组合 from position_db.rwa.get_mRWA_IRCMtM(@BalanceDate))d on ab.组合代码=d.组合)abd 
				left join	
				(select distinct 组合,sum(PnL) PnL from(select left(组合,2) 组合,PnL 
						from Position_DB.rwa.get_pnl('20150105',@BalanceDate))f  group by 组合
					union all select 组合,pnl 
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)where 组合<>'大宗'
					union all select '公司整体',sum(pnl)
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)
				)c on abd.AccId=c.组合
	)abdc


)








GO
