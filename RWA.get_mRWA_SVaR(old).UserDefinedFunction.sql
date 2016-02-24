USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_SVaR(old)]    Script Date: 2016/2/24 11:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-14,更新日期2015-12-02>
-- Description:	<获得市场风险计算压力VaR的持仓数据>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_SVaR(old)]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select * from

(

	select 

	@BalanceDate as Balance_Date
	,SVaRType
	,RiskFactor
	,到期天数
	,CurveName
	,sum(ValuationFactor) as '公司总计'
	,sum(case when 组合 in( '固收交易', '固收销售','固收财富管理') then ValuationFactor else 0 end) as '固定收益部'
	,sum(case 组合 when '固收交易' then ValuationFactor else 0 end) as '固收交易'
	,sum(case 组合 when '固收财富管理' then ValuationFactor else 0 end) as '固收财富管理'
	,sum(case 组合 when '固收销售' then ValuationFactor else 0 end) as '固收销售'
	,sum(case 组合 when '夹层投资部' then ValuationFactor else 0 end) as '夹层投资部'
	,sum(case 组合 when '资金运营部' then ValuationFactor  else 0 end) as '资金运营部'
	,sum(case when 组合 in( '权益应急','股票交易') then ValuationFactor else 0 end) as '权益投资部'
	,sum(case when 组合 ='权益应急'then ValuationFactor else 0 end) as '权益应急'
	,sum(case when 组合 ='股票交易'then ValuationFactor else 0 end) as '股票交易'
	,sum(case 组合 when '股衍业务线' then ValuationFactor else 0 end) as '股衍业务线'
	,sum(case when 组合 in('另类量化','另类应急') then ValuationFactor else 0 end) as '另类投资业务线'
	,sum(case when 组合 ='另类量化' then ValuationFactor else 0 end) as '另类量化'
	,sum(case when 组合 ='另类应急' then ValuationFactor else 0 end) as '另类应急'
	,sum(case when 组合 in('证金券池','证金股权及其他') then ValuationFactor else 0 end) as '证券金融业务线'
	,sum(case 组合 when '证金券池' then ValuationFactor else 0 end) as '证金券池'
	,sum(case 组合 when '证金股权及其他' then ValuationFactor else 0 end) as '证金股权及其他'
	,sum(case 组合 when '其他' then ValuationFactor else 0 end) as  '其他'

	from
	(
		select SVaRType,RiskFactor,组合,到期天数,CurveName
			,sum(ValuationFactor) as ValuationFactor
		from 
		(
			select 

			(case AccId when 'FIJY' then '固收交易' when 'FIZJ' then '固收财富管理'
			when 'FIXS' then '固收销售'	when 'JYSDEV' then '股衍业务线' 
			else (case when DeptId= 'JCTZ' then  '夹层投资部' when DeptId = 'ZJYY' then '资金运营部'
			when SubAccId = 'ZJBRQC' then '证金券池' when (DeptID='ZQJR'and SubAccId<>'ZJBRQC') then '证金股权及其他'
			when (AccId='JYSSTOCK'and SubAccId in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '权益应急'
			when (AccId='JYSSTOCK'and SubAccId not in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '股票交易'
			when (AccId='Quant'and SubAccId='LLTZ-YYZC')then '另类应急'
			when (AccId='Quant'and SubAccId<>'LLTZ-YYZC') then  '另类量化'
			else '其他' end) end) as 组合
	
				,(case when [标的代码]='000300.SH' then 'Equity'else (case
				when SecuCategory='SWAP' then 'IRS'
				when (SecuCategory='Bond' or SecuCategory='FwdBond' or SecuCategory='OVERNIGHT' ) then 'Bond' --or (secucategory='Fund'and MK_Duration is not null)
			--注意，并未处理债券型基金！
				when (SecuCategory='Fund' or Secucategory='ETF' or Secucategory='EquityOption' or Secucategory='Commodity') then 'Fund'
				when (SecuCategory='Equity' or Secucategory='EquityFuture' ) then 'Equity'
				when SecuCategory='CVBond' then 'CVBond'
				else [SecuCategory] end) end
				) as SVaRType

				,(case when SecuCategory='SWAP'then
				left([标的代码],CHARINDEX('.',[标的代码]) )+(case     --近似处理，更好的方法是根据到期日对收益率曲线数据做插值（同债券）
				when DATEDIFF ( day,Balance_Date ,SettleDay ) < 0 then 'ERROR'
				when DATEDIFF ( day,Balance_Date ,SettleDay ) < 2 then '1d'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<100 then  '3m'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<190 then  '6m'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<285 then  '9m'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<375 then  '1y'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<750 then  '2y'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<1110 then  '3y'
				when DATEDIFF ( day,Balance_Date ,SettleDay )<1470 then  '4y'
				else '5y' end) 	else 标的代码 end
				) as RiskFactor  

				,(case SecuCategory when 'SWAP' then DV01*10000
										when 'EquityOption' then [DollorDelta1%]
										when 'FwdBond' then -Notional* MK_Duration 							
										when 'Bond' then -PresentValue_CNY *MK_Duration 
										when 'OverNight' then -PresentValue_CNY *MK_Duration
										when 'BondFuture' then (case when left(SECUCODE,2)='TF' then (-5)*PresentValue_CNY
																	else (-10)*PresentValue_CNY end)  
										else PresentValue_CNY end
				) as ValuationFactor

				,(case when secucategory='BondFuture' then '交易所固定利率国债收益率曲线' else CurveName end)as CurveName

				,(case  when SecuCategory in ( 'Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
						when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
						else NULL end
				) as 到期天数
							  
			from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
			and RWA有效性=1
		) as a
		group by SVaRType,RiskFactor,到期天数,CurveName,组合
	) as b
	group by SVaRType,RiskFactor,到期天数,CurveName

	--order by SVaRType,RiskFactor
)as c
where (公司总计<>0 or 固收交易<>0 or 固收财富管理<>0 or 固收销售<>0
or 夹层投资部<>0 or 资金运营部<>0 or 权益投资部<>0 or 权益应急<>0 or 股票交易<>0 
or 股衍业务线<>0 or 另类量化<>0 or 另类应急<>0 or 另类投资业务线<>0 
or 证金券池<>0 or 证金股权及其他<>0 or 其他<>0 )


)








GO
