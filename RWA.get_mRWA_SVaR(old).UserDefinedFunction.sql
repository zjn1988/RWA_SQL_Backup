USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_SVaR(old)]    Script Date: 2016/2/24 11:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-14,��������2015-12-02>
-- Description:	<����г����ռ���ѹ��VaR�ĳֲ�����>
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
	,��������
	,CurveName
	,sum(ValuationFactor) as '��˾�ܼ�'
	,sum(case when ��� in( '���ս���', '��������','���ղƸ�����') then ValuationFactor else 0 end) as '�̶����沿'
	,sum(case ��� when '���ս���' then ValuationFactor else 0 end) as '���ս���'
	,sum(case ��� when '���ղƸ�����' then ValuationFactor else 0 end) as '���ղƸ�����'
	,sum(case ��� when '��������' then ValuationFactor else 0 end) as '��������'
	,sum(case ��� when '�в�Ͷ�ʲ�' then ValuationFactor else 0 end) as '�в�Ͷ�ʲ�'
	,sum(case ��� when '�ʽ���Ӫ��' then ValuationFactor  else 0 end) as '�ʽ���Ӫ��'
	,sum(case when ��� in( 'Ȩ��Ӧ��','��Ʊ����') then ValuationFactor else 0 end) as 'Ȩ��Ͷ�ʲ�'
	,sum(case when ��� ='Ȩ��Ӧ��'then ValuationFactor else 0 end) as 'Ȩ��Ӧ��'
	,sum(case when ��� ='��Ʊ����'then ValuationFactor else 0 end) as '��Ʊ����'
	,sum(case ��� when '����ҵ����' then ValuationFactor else 0 end) as '����ҵ����'
	,sum(case when ��� in('��������','����Ӧ��') then ValuationFactor else 0 end) as '����Ͷ��ҵ����'
	,sum(case when ��� ='��������' then ValuationFactor else 0 end) as '��������'
	,sum(case when ��� ='����Ӧ��' then ValuationFactor else 0 end) as '����Ӧ��'
	,sum(case when ��� in('֤��ȯ��','֤���Ȩ������') then ValuationFactor else 0 end) as '֤ȯ����ҵ����'
	,sum(case ��� when '֤��ȯ��' then ValuationFactor else 0 end) as '֤��ȯ��'
	,sum(case ��� when '֤���Ȩ������' then ValuationFactor else 0 end) as '֤���Ȩ������'
	,sum(case ��� when '����' then ValuationFactor else 0 end) as  '����'

	from
	(
		select SVaRType,RiskFactor,���,��������,CurveName
			,sum(ValuationFactor) as ValuationFactor
		from 
		(
			select 

			(case AccId when 'FIJY' then '���ս���' when 'FIZJ' then '���ղƸ�����'
			when 'FIXS' then '��������'	when 'JYSDEV' then '����ҵ����' 
			else (case when DeptId= 'JCTZ' then  '�в�Ͷ�ʲ�' when DeptId = 'ZJYY' then '�ʽ���Ӫ��'
			when SubAccId = 'ZJBRQC' then '֤��ȯ��' when (DeptID='ZQJR'and SubAccId<>'ZJBRQC') then '֤���Ȩ������'
			when (AccId='JYSSTOCK'and SubAccId in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then 'Ȩ��Ӧ��'
			when (AccId='JYSSTOCK'and SubAccId not in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '��Ʊ����'
			when (AccId='Quant'and SubAccId='LLTZ-YYZC')then '����Ӧ��'
			when (AccId='Quant'and SubAccId<>'LLTZ-YYZC') then  '��������'
			else '����' end) end) as ���
	
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
				else '5y' end) 	else ��Ĵ��� end
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

				,(case when secucategory='BondFuture' then '�������̶����ʹ�ծ����������' else CurveName end)as CurveName

				,(case  when SecuCategory in ( 'Bond','FwdBond','OVERNIGHT' ) then DATEDIFF(DAY,@BalanceDate,B_MTR_Date) 
						when secucategory='BondFuture' then (case left(secucode,2) when 'TF' then 1825 else 3650 end)
						else NULL end
				) as ��������
							  
			from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
			and RWA��Ч��=1
		) as a
		group by SVaRType,RiskFactor,��������,CurveName,���
	) as b
	group by SVaRType,RiskFactor,��������,CurveName

	--order by SVaRType,RiskFactor
)as c
where (��˾�ܼ�<>0 or ���ս���<>0 or ���ղƸ�����<>0 or ��������<>0
or �в�Ͷ�ʲ�<>0 or �ʽ���Ӫ��<>0 or Ȩ��Ͷ�ʲ�<>0 or Ȩ��Ӧ��<>0 or ��Ʊ����<>0 
or ����ҵ����<>0 or ��������<>0 or ����Ӧ��<>0 or ����Ͷ��ҵ����<>0 
or ֤��ȯ��<>0 or ֤���Ȩ������<>0 or ����<>0 )


)








GO
