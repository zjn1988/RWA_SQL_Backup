USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_FwdBond]    Script Date: 2016/2/24 11:15:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-14,,>
-- Description:	<获得债券远期数据用于交易对手信用风险RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_FwdBond]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/***** 债券远期交易对手信用风险数据表（除利率曲线数据）*****/

/***** 更新日期：2015年10月14日 版本：v1.1 *****/


select 
	Balance_date,SubAccId,AccId,组合代码,SecuCategory,CounterpartyName,SecuCode
	,CONVERT(varchar(10), Settleday , 111) as Settleday
	,[固定利率]
	,Notional
	,CurveName
	,曲线序号
	--,(case left([标的代码],CHARINDEX('.',[标的代码])-1) 
	--	when 'SHIBOR-1D' then 1 
	--	when 'FR007' then 2 
	--	when 'SHIBOR-3M' then 3 
	--	when 'DEPO_F01Y' then 4 
	--	else 0 end) as 曲线代码
	--,PAY_FREQ
	,[标的代码]
	,PresentValue_CNY
	,内评等级
	,PD
	,BankULPD as 'UL_PD（金融机构）'
	,'60%' as 'LGD'
	,(datediff(day,Balance_date,(case when SettleDay<(@BalanceDate+182) then SettleDay 
									else (@BalanceDate+182)end))/365* mAdjust1+ mAdjust2
									) as M调整
	,(BankULPD*(datediff(day,Balance_date,(case when SettleDay<(@BalanceDate+182) then SettleDay 
									else (@BalanceDate+182)end))/365* mAdjust1+ mAdjust2
									) *12.5*0.6) as 'K*12.5（LGD=60%）'  --已经乘了12.5
	,--(case PAY_FREQ 
		--when '季付' then 4 
		--when '年付' then 1 
		--else 4 end ) 
		'' as 年付次数 --若非季付年付，则按照季付处理，【每次检查】


from
(	
	select Balance_date,SubAccId,AccId,组合代码,SecuCategory,SecuCode,Settleday,固定利率
		,Notional,PAY_FREQ,[标的代码],PresentValue_CNY,CounterpartyName,内评等级,a.CurveName,曲线序号
	from
	( 
		select Balance_date,SubAccId,AccId,组合代码,SecuCategory,SecuCode,Settleday,固定利率
		,Notional,PAY_FREQ,[标的代码],PresentValue_CNY,CounterpartyName,内评等级,CurveName
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and RWA有效性=1 and SecuCategory='FwdBond'
		and CounterpartyName is not null
		--and CounterpartyName not in ('中信证券%','CSI%') 
	)as a
	left join 
	(
		select * from (SELECT ROW_NUMBER() OVER( ORDER BY CurveName ) AS 曲线序号,tmp1.* 
		FROM( SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and Secucategory='FwdBond'and RWA有效性=1and CounterpartyName is not null ) as tmp1 --order by CurveName
		) as tmp2
	)as b
	on a.CurveName=b.CurveName
)as ab
left join
(
	select InnerRating,PD,BankULPD,mAdjust1,mAdjust2
	from Position_DB.RWA.parameter_ULPDMatrix() 
)as c
on ab.内评等级 = c.InnerRating

--order by CounterpartyName,组合代码,AccId,SubAccId


)




GO
