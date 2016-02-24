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
-- Description:	<���ծȯԶ���������ڽ��׶������÷���RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_FwdBond]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/***** ծȯԶ�ڽ��׶������÷������ݱ��������������ݣ�*****/

/***** �������ڣ�2015��10��14�� �汾��v1.1 *****/


select 
	Balance_date,SubAccId,AccId,��ϴ���,SecuCategory,CounterpartyName,SecuCode
	,CONVERT(varchar(10), Settleday , 111) as Settleday
	,[�̶�����]
	,Notional
	,CurveName
	,�������
	--,(case left([��Ĵ���],CHARINDEX('.',[��Ĵ���])-1) 
	--	when 'SHIBOR-1D' then 1 
	--	when 'FR007' then 2 
	--	when 'SHIBOR-3M' then 3 
	--	when 'DEPO_F01Y' then 4 
	--	else 0 end) as ���ߴ���
	--,PAY_FREQ
	,[��Ĵ���]
	,PresentValue_CNY
	,�����ȼ�
	,PD
	,BankULPD as 'UL_PD�����ڻ�����'
	,'60%' as 'LGD'
	,(datediff(day,Balance_date,(case when SettleDay<(@BalanceDate+182) then SettleDay 
									else (@BalanceDate+182)end))/365* mAdjust1+ mAdjust2
									) as M����
	,(BankULPD*(datediff(day,Balance_date,(case when SettleDay<(@BalanceDate+182) then SettleDay 
									else (@BalanceDate+182)end))/365* mAdjust1+ mAdjust2
									) *12.5*0.6) as 'K*12.5��LGD=60%��'  --�Ѿ�����12.5
	,--(case PAY_FREQ 
		--when '����' then 4 
		--when '�긶' then 1 
		--else 4 end ) 
		'' as �긶���� --���Ǽ����긶�����ռ���������ÿ�μ�顿


from
(	
	select Balance_date,SubAccId,AccId,��ϴ���,SecuCategory,SecuCode,Settleday,�̶�����
		,Notional,PAY_FREQ,[��Ĵ���],PresentValue_CNY,CounterpartyName,�����ȼ�,a.CurveName,�������
	from
	( 
		select Balance_date,SubAccId,AccId,��ϴ���,SecuCategory,SecuCode,Settleday,�̶�����
		,Notional,PAY_FREQ,[��Ĵ���],PresentValue_CNY,CounterpartyName,�����ȼ�,CurveName
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and RWA��Ч��=1 and SecuCategory='FwdBond'
		and CounterpartyName is not null
		--and CounterpartyName not in ('����֤ȯ%','CSI%') 
	)as a
	left join 
	(
		select * from (SELECT ROW_NUMBER() OVER( ORDER BY CurveName ) AS �������,tmp1.* 
		FROM( SELECT distinct CurveName  from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and Secucategory='FwdBond'and RWA��Ч��=1and CounterpartyName is not null ) as tmp1 --order by CurveName
		) as tmp2
	)as b
	on a.CurveName=b.CurveName
)as ab
left join
(
	select InnerRating,PD,BankULPD,mAdjust1,mAdjust2
	from Position_DB.RWA.parameter_ULPDMatrix() 
)as c
on ab.�����ȼ� = c.InnerRating

--order by CounterpartyName,��ϴ���,AccId,SubAccId


)




GO
