USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_IRCMtMtesting]    Script Date: 2016/2/24 11:17:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-16,������2015-12-02>
-- Description:	<����г����ռ����������յĳֲ�����,����RWA����>
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
	select distinct subaccid 	--�˻�����
		,��Ĵ���
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
		
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA��Ч��=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --ָ��������IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		--and (accid like '����%'or accid='Ӧ��-����' )
		--and ��ϴ���<>'0700' --������Ʒ�������
	group by ��Ĵ���,SECUCATEGORY,SubAccId
)
union all
(
	select '0000' 	 --��˾����
		,��Ĵ���
		, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end) as MtM
		,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end) as 'IRCType'
		,convert(varchar(10),@BalanceDate,111) Balance_Date
		
	from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
		and RWA��Ч��=1 
		and Underlying not in ('000300.SH','000016.SH','000905.SH')  --ָ��������IRC
		and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		--and (accid like '����%'or accid='Ӧ��-����' )
	group by ��Ĵ���,SECUCATEGORY
)

)









GO
