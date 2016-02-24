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
-- Description:	<�ڶ��棬�����˰�ʽ���˻���Ϣ��������ֶ���>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_SVaR_testing]
( 
	@BalanceDate DATE

	)

RETURNS TABLE 
AS
RETURN 
( 
select @BalanceDate as Balance_Date,SVaRType,RiskFactor,��������,CurveName
		,sum(ValuationFactor) as ValuationFactor,���
	from 
	(

/*�˻�����*/
		select 
			distinct --��ϴ���
			subaccid as ���
			,(case when [��Ĵ���]='000300.SH' then 'Equity'else (case
			when SecuCategory='SWAP' then 'IRS'
			when (SecuCategory='Bond' or SecuCategory='FwdBond' or SecuCategory='OVERNIGHT' ) then 'Bond' --or (secucategory='Fund'and MK_Duration is not null)
		--ע�⣬��δ����ծȯ�ͻ���
			when (SecuCategory='Fund' or Secucategory='ETF' or Secucategory='EquityOption' or Secucategory='Commodity') then 'Fund'
			when (SecuCategory='Equity' or Secucategory='EquityFuture' ) then 'Equity'
			when SecuCategory='CVBond' then 'CVBond'
			else [SecuCategory] end) end
			) as SVaRType

			,(case when SecuCategory='SWAP'then
			left([��Ĵ���],CHARINDEX('.',[��Ĵ���]) )+(case     --���ƴ������õķ����Ǹ��ݵ����ն�������������������ֵ��ͬծȯ��
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
			��Ĵ��� 
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

			,(case when secucategory='BondFuture' then '�������̶����ʹ�ծ����������' else CurveName end)as CurveName

			,(case  when SecuCategory in ( 'Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
					when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
					else NULL end
			) as ��������
			,balance_date
							  
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate -- in('20150630','20150731','20150831','20150930','20151030','20151130','20151231') 
		and RWA��Ч��=1 
		and ��ϴ���<>'0700' --���ڲ������
		and accid like '%����%' 
	) as a
	where valuationfactor<>0
	group by SVaRType,RiskFactor,��������,CurveName,���
)
union all

/*���Ų���*/
(
select @BalanceDate as Balance_Date,SVaRType,RiskFactor,��������,CurveName
		,sum(ValuationFactor) as ValuationFactor,���
	from 
	(
		select 


			distinct left(��ϴ���,2)+'00' as ���
			,(case when [��Ĵ���]='000300.SH' then 'Equity'else (case
			when SecuCategory='SWAP' then 'IRS'
			when (SecuCategory='Bond' or SecuCategory='FwdBond' or SecuCategory='OVERNIGHT' ) then 'Bond' --or (secucategory='Fund'and MK_Duration is not null)
		--ע�⣬��δ����ծȯ�ͻ���
			when (SecuCategory='Fund' or Secucategory='ETF' or Secucategory='EquityOption' or Secucategory='Commodity') then 'Fund'
			when (SecuCategory='Equity' or Secucategory='EquityFuture' ) then 'Equity'
			when SecuCategory='CVBond' then 'CVBond'
			else [SecuCategory] end) end
			) as SVaRType

			,(case when SecuCategory='SWAP'then
			left([��Ĵ���],CHARINDEX('.',[��Ĵ���]) )+(case     --���ƴ������õķ����Ǹ��ݵ����ն�������������������ֵ��ͬծȯ��
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
			��Ĵ��� 
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

			,(case when secucategory='BondFuture' then '�������̶����ʹ�ծ����������' else CurveName end)as CurveName

			,(case  when SecuCategory in ('Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
					when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
					else NULL end
			) as ��������
				  
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate 
		and RWA��Ч��=1 
		and accid like '%����%' 
	) as b
	where valuationfactor<>0
	group by SVaRType,RiskFactor,��������,CurveName,���

)







GO
