USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_IRCMtM]    Script Date: 2016/2/24 11:17:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-16,更新于2015-12-02>
-- Description:	<获得市场风险计算新增风险的持仓数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_IRCMtM]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


(
	select distinct 组合代码 as 组合 	--公司层面
		,标的代码
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA有效性=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		and 组合代码<>'0700' --大宗商品不分组合
	group by 标的代码,SECUCATEGORY,组合代码,AccID,SubAccId
)
union all
(
select distinct left(组合代码,2)+'00' 	--部门层面
		,标的代码
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA有效性=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
	group by 标的代码,SECUCATEGORY,组合代码,AccID,SubAccId
)
union all
(
	select '0000' as 组合 	 --公司层面
		,标的代码
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA有效性=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
	group by 标的代码,SECUCATEGORY,组合代码,AccID,SubAccId
)

)







GO
