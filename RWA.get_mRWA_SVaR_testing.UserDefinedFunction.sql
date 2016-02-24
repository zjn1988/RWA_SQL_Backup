USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_SVaR_testing]    Script Date: 2016/2/24 11:18:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-02,>
-- Description:	<第二版，更新了版式，账户信息放在组合字段中>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_SVaR_testing]
( 
	@BalanceDate DATE

	)

RETURNS TABLE 
AS
RETURN 
( 
select @BalanceDate as Balance_Date,SVaRType,RiskFactor,到期天数,CurveName
		,sum(ValuationFactor) as ValuationFactor,组合
	from 
	(

/*账户层面*/
		select 
			distinct --组合代码
			subaccid as 组合
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
			else '5y' end) 	else 
			标的代码 
			end) 
			as RiskFactor
			
			,(case SecuCategory when 'SWAP' then DV01*10000
									when 'EquityOption' then [DollorDelta1%]
									when 'FwdBond' then -Notional* MK_Duration 							
									when 'Bond' then -PresentValue_CNY *MK_Duration 
									when 'OverNight' then -PresentValue_CNY *MK_Duration
									when 'BondFuture' then (case when left(SECUCODE,2)='TF' then (-5)*PresentValue_CNY
																else (-10)*PresentValue_CNY end)  
									else 
									PresentValue_CNY 
									end) 
									as ValuationFactor

			,(case when secucategory='BondFuture' then '交易所固定利率国债收益率曲线' else CurveName end)as CurveName

			,(case  when SecuCategory in ( 'Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
					when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
					else NULL end
			) as 到期天数
			,balance_date
							  
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate -- in('20150630','20150731','20150831','20150930','20151030','20151130','20151231') 
		and RWA有效性=1 
		and 组合代码<>'0700' --大宗不分组合
		and accid like '%固收%' 
	) as a
	where valuationfactor<>0
	group by SVaRType,RiskFactor,到期天数,CurveName,组合
)
union all

/*部门层面*/
(
select @BalanceDate as Balance_Date,SVaRType,RiskFactor,到期天数,CurveName
		,sum(ValuationFactor) as ValuationFactor,组合
	from 
	(
		select 


			distinct left(组合代码,2)+'00' as 组合
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
			else '5y' end) 	else 
			标的代码 
			end) 
			as RiskFactor  

			,(case SecuCategory when 'SWAP' then DV01*10000
									when 'EquityOption' then [DollorDelta1%]
									when 'FwdBond' then -Notional* MK_Duration 							
									when 'Bond' then -PresentValue_CNY *MK_Duration 
									when 'OverNight' then -PresentValue_CNY *MK_Duration
									when 'BondFuture' then (case when left(SECUCODE,2)='TF' then (-5)*PresentValue_CNY
																else (-10)*PresentValue_CNY end)  
									else 
									PresentValue_CNY 
									end) 
									as ValuationFactor

			,(case when secucategory='BondFuture' then '交易所固定利率国债收益率曲线' else CurveName end)as CurveName

			,(case  when SecuCategory in ('Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
					when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
					else NULL end
			) as 到期天数
				  
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate 
		and RWA有效性=1 
		and accid like '%固收%' 
	) as b
	where valuationfactor<>0
	group by SVaRType,RiskFactor,到期天数,CurveName,组合

)







GO
