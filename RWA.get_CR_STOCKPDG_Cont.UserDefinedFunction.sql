USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CR_STOCKPDG_Cont]    Script Date: 2016/2/24 11:17:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-11-06,,>
-- Description:	<��ù�Ȩ��Ѻ�ع�����,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CR_STOCKPDG_Cont]
( 
	@BalanceDate DATETIME 
)

RETURNS TABLE 
AS
RETURN 
(
	

select 
	distinct �ϲ����д���,������,ҵ������,����,�ϲ����пͻ�,sum(���屾��)as ���屾��,sum(�ܸ�ծ)as �ܸ�ծ
	,sum(���ʲ�) as ���ʲ�,sum(���ʲ�)/sum(�ܸ�ծ) as ά�ֵ�������,�ϲ����к�Լ������
from
(
	select ������,ҵ������,����
	,case when �ϲ����д��� is null then ��Լ���� else �ϲ����д��� end �ϲ����д���
	,case when �ϲ����д��� is null then �ͻ����� else �ϲ����пͻ� end �ϲ����пͻ�
	,���屾��,�ܸ�ծ,���ʲ�
	,case when �ϲ����д��� is null then ��Լ������ else �ϲ����к�Լ������ end �ϲ����к�Լ������
	from
	(	
			select CONVERT(varchar(10), @BalanceDate , 111) as ������ 
				,assettype as ҵ������
				,dept as ����
				,contractid as ��Լ����
				,clientid as �ͻ�����
				,notional as ���屾��
				,debt as �ܸ�ծ
				,CONVERT(varchar(10), maturity , 111)  as ��Լ������
			from Credit_DB.C_position.acc_balance_contract 
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
	) as cont
	left join
	(
		select distinct contractid
			,sum(cltr_value) as ���ʲ�
		from Credit_DB.C_position.acc_balance_collateral
		where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
		group by contractid
	) as cltr
	on cont.��Լ����=cltr.contractid
	left join [Credit_DB].[C_config].[View_StockPledge_Merge]  m1
	on cont.��Լ����=m1.src_contractid
	left join 
	(	
			select contractid as �ϲ����д���
				,clientid as �ϲ����пͻ�
				,CONVERT(varchar(10), maturity , 111)  as �ϲ����к�Լ������
			from Credit_DB.C_position.acc_balance_contract 
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
	) as m2
	on m1.merge_contractid=m2.�ϲ����д���
)summary
group by �ϲ����д���,������,ҵ������,����,�ϲ����пͻ�,�ϲ����к�Լ������


	
)







GO
