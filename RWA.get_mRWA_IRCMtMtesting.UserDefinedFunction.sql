USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_IRCMtMtesting]    Script Date: 2016/2/24 11:17:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-16,更新于2015-12-02>
-- Description:	<获得市场风险计算新增风险的持仓数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_IRCMtMtesting]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


(
	select distinct subaccid 	--账户层面
		,标的代码
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
		
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA有效性=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		--and (accid like '交易%'or accid='应急-交易' )
		--and 组合代码<>'0700' --大宗商品不分组合
	group by 标的代码,SECUCATEGORY,SubAccId
)
union all
(
	select '0000' 	 --公司层面
		,标的代码
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
		
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA有效性=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		--and (accid like '交易%'or accid='应急-交易' )
	group by 标的代码,SECUCATEGORY
)

)









GO
