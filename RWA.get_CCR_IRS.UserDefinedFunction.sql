USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRS]    Script Date: 2016/2/24 11:15:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/***** 利率互换交易对手信用风险数据表（除利率曲线数据）*****/

/***** 更新日期：2015年10月14日 版本：v1.2 *****/

select 
	Balance_date,SubAccId,AccId,left(Accid,2) DeptId,SecuCategory,CounterpartyName,SecuCode
	,CONVERT(varchar(20), Settleday , 111) as Settleday
	,[固定利率]
	,(case PAY_FREQ 
		when '季付' then 4 
		when '年付' then 1 
		else 4 end ) as 年付次数 --若非季付年付，则按照季付处理，【每次检查】
	,Notional
	,(case left([标的代码],CHARINDEX('.',[标的代码])-1) 
		when 'SHIBOR-1D' then 2 
		when 'FR007' then 1 
		when 'SHIBOR-3M' then 4 
		when 'DEPO_F01Y' then 3 
		else 0 end) as 曲线代码
	,PAY_FREQ
	,[标的代码]
	,PresentValue_CNY
	,内评等级
	,PD
	,BankULPD as 'UL_PD（金融机构）'
	,0.6 as 'LGD'
	,(cast(datediff(year,Balance_date,SettleDay) as float)* mAdjust1+ mAdjust2) as M调整
	,(BankULPD*(cast(datediff(year,Balance_date,SettleDay)as float)* mAdjust1+ mAdjust2)*12.5*0.6) as 'K*12.5（LGD=60%）'  --已经乘了12.5
	,AccId+'_'+CounterpartyName as 账户#
	,left(Accid,2)+'_'+CounterpartyName as 部门#

	from
	( 
		select Balance_date,SubAccId,AccId,SecuCategory,SecuCode,Settleday,固定利率
		,Notional,PAY_FREQ,[标的代码],PresentValue_CNY,CounterpartyName,内评等级
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and RWA有效性=1 and SecuCategory='SWAP' and counterparter not like 'CSI%'
		and counterparter not like '中信证券%' and counterpartyname is not null
	)as a
	left join 
	(
		select InnerRating,PD,BankULPD,mAdjust1,mAdjust2
		from Position_DB.RWA.parameter_ULPDMatrix() 
	)as b
	on a.内评等级 = b.InnerRating

--order by CounterpartyName,DeptId,AccId,SubAccId

)








GO
