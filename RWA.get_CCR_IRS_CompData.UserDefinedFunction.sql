USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRS_CompData]    Script Date: 2016/2/24 11:16:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-19,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS_CompData]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select Balance_date,�˻���Χ,�������#,�������,SecuCode,Settleday,�̶�����,�긶����,Notional,���ߴ���	
,PresentValue_CNY	
from	
(	
	select * from (SELECT ROW_NUMBER() OVER( ORDER BY ������� ) AS �������#,tmp1.* 
	FROM( select distinct CounterpartyName as ������� from Position_DB.rwa.get_CCR_IRS(@balancedate)) as tmp1 )tmp2
) as Acc1	
left join	
(	
	select  Balance_date,'��˾' as �˻���Χ,CounterpartyName as ʶ����,SecuCode,Settleday,�̶�����,�긶����,Notional,���ߴ���
	,��Ĵ���,PresentValue_CNY
	from Position_DB.rwa.get_CCR_IRS(@balancedate)
) as Acc2	
on �������=ʶ����	

)


GO
