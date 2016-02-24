USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CR_STOCKPDG_Cltr]    Script Date: 2016/2/24 11:16:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-11-06,,>
-- Description:	<��ù�Ȩ��Ѻ�ع�����,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CR_STOCKPDG_Cltr]
( 
	@BalanceDate DATETIME 
)

RETURNS TABLE 
AS
RETURN 
(
	
select CONVERT(varchar(10), @BalanceDate , 111) as ������,�ϲ����д���,��Ѻȯ����,��Ѻȯ����,��Ѻȯ��ֵ
from 
(
	select distinct �ϲ����д��� �ϲ����д��� from Position_DB.RWA.get_CR_STOCKPDG_Cont(@BalanceDate) 
)Cont1
left join 
(		
	select distinct AdjContractId
	,��Ѻȯ����,sum(��Ѻȯ����) as ��Ѻȯ����,sum(��Ѻȯ��ֵ)as ��Ѻȯ��ֵ
	from 
	(select case when merge_contractid is null then contractid else merge_contractid end AdjContractId
		,��Ѻȯ����,��Ѻȯ����,��Ѻȯ��ֵ
		from 
		(
			select 
				contractid
				,case cltr_mkt when 'XSHG' then cltr_secid +'.SH'
								when 'XSHE' then cltr_secid +'.SZ'END 
				as ��Ѻȯ����
				,cltr_amount as ��Ѻȯ����
				,cltr_value as ��Ѻȯ��ֵ
			from Credit_DB.C_position.acc_balance_collateral
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'and cltr_assettype<>'CASH'
		)cltr
		left join [Credit_DB].[C_config].[View_StockPledge_Merge]  m1
		on cltr.contractid=m1.src_contractid
	) m2 
	group by AdjContractId,��Ѻȯ����
)Dtl
on Cont1.�ϲ����д���=Dtl.AdjContractId

	
)






GO
