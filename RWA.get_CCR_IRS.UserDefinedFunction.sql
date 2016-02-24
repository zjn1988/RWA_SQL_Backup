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
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/***** ���ʻ������׶������÷������ݱ��������������ݣ�*****/

/***** �������ڣ�2015��10��14�� �汾��v1.2 *****/

select 
	Balance_date,SubAccId,AccId,left(Accid,2) DeptId,SecuCategory,CounterpartyName,SecuCode
	,CONVERT(varchar(20), Settleday , 111) as Settleday
	,[�̶�����]
	,(case PAY_FREQ 
		when '����' then 4 
		when '�긶' then 1 
		else 4 end ) as �긶���� --���Ǽ����긶�����ռ���������ÿ�μ�顿
	,Notional
	,(case left([��Ĵ���],CHARINDEX('.',[��Ĵ���])-1) 
		when 'SHIBOR-1D' then 2 
		when 'FR007' then 1 
		when 'SHIBOR-3M' then 4 
		when 'DEPO_F01Y' then 3 
		else 0 end) as ���ߴ���
	,PAY_FREQ
	,[��Ĵ���]
	,PresentValue_CNY
	,�����ȼ�
	,PD
	,BankULPD as 'UL_PD�����ڻ�����'
	,0.6 as 'LGD'
	,(cast(datediff(year,Balance_date,SettleDay) as float)* mAdjust1+ mAdjust2) as M����
	,(BankULPD*(cast(datediff(year,Balance_date,SettleDay)as float)* mAdjust1+ mAdjust2)*12.5*0.6) as 'K*12.5��LGD=60%��'  --�Ѿ�����12.5
	,AccId+'_'+CounterpartyName as �˻�#
	,left(Accid,2)+'_'+CounterpartyName as ����#

	from
	( 
		select Balance_date,SubAccId,AccId,SecuCategory,SecuCode,Settleday,�̶�����
		,Notional,PAY_FREQ,[��Ĵ���],PresentValue_CNY,CounterpartyName,�����ȼ�
		from [Position_DB].[RWA].[mRWA_All] where balance_date=@BalanceDate
		and RWA��Ч��=1 and SecuCategory='SWAP' and counterparter not like 'CSI%'
		and counterparter not like '����֤ȯ%' and counterpartyname is not null
	)as a
	left join 
	(
		select InnerRating,PD,BankULPD,mAdjust1,mAdjust2
		from Position_DB.RWA.parameter_ULPDMatrix() 
	)as b
	on a.�����ȼ� = b.InnerRating

--order by CounterpartyName,DeptId,AccId,SubAccId

)








GO
