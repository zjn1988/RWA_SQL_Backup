USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_Amount_Account]    Script Date: 2016/2/24 11:14:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/* =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-16,,>
-- Description:	<���ڼ���RWA�ھ��µ�Ͷ�ʹ�ģ>

ǰ������:���ֹ�ִ�й����յ�mRWA_all�洢����

-- ===========================================*/
CREATE FUNCTION [RWA].[get_Amount_Account]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select '0000' ��ϴ���,'��˾����' AccId,sum(case when Ͷ�ʹ�ģ>0 then Ͷ�ʹ�ģ else -Ͷ�ʹ�ģ end) �ܹ�ģ,sum(Ͷ�ʹ�ģ) ����ģ,Balance_date
from(	select distinct ֤ȯʶ����,secucategory,secucode,sum(Ͷ�ʹ�ģ) Ͷ�ʹ�ģ,Balance_date
	from position_db.rwa.get_Amount_Secu(@balancedate) 
	group by ֤ȯʶ����,secucategory,secucode,Balance_date
)b group by Balance_date

union all

select distinct ��ϴ���,Accid,sum(case when Ͷ�ʹ�ģ>0 then Ͷ�ʹ�ģ else -Ͷ�ʹ�ģ end) �ܹ�ģ,sum(Ͷ�ʹ�ģ) ����ģ,Balance_date
from(	select distinct ֤ȯʶ����,left(��ϴ���,2)+'00' ��ϴ���,left(Accid,2) Accid,secucategory,secucode,sum(Ͷ�ʹ�ģ) Ͷ�ʹ�ģ,Balance_date
	from position_db.rwa.get_Amount_Secu(@balancedate)
	group by ֤ȯʶ����,��ϴ���,accid,secucategory,secucode,Balance_date
)a group by ��ϴ���,Accid,Balance_date

union all

select distinct ��ϴ���,AccId,sum(case when Ͷ�ʹ�ģ>0 then Ͷ�ʹ�ģ else -Ͷ�ʹ�ģ end) �ܹ�ģ,sum(Ͷ�ʹ�ģ) ����ģ,Balance_date
from position_db.rwa.get_Amount_Secu(@balancedate)
where ��ϴ���<>'0700'
group by ��ϴ���,accid,Balance_date



)






GO
