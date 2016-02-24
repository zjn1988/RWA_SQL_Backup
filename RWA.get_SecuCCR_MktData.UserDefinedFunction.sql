USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_MktData]    Script Date: 2016/2/24 13:09:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-09,,>
-- Description:	<>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_MktData]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

--declare @balancedate datetime
--set @balancedate='2015-11-30'


select balance_date,abe.��ʷ����,abe.֤ȯ����
	,case when �ǵ��� is null or �ǵ���=0 then (SELECT cast(left(v.changed,len(v.changed)-1) as numeric(18,4))/100	
												FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE v.localCode='000300' and balanceDate=abe.��ʷ����)
			else �ǵ��� end �ǵ���

from(	select ��ʷ����,֤ȯ����
	from( select distinct ��ʷ����,@balancedate as balancedate
		from (select ����,�г� from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate))a left join (SELECT balancedate ��ʷ����,v.localcode,v.mic
		FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE balancedate between dateadd(year,-6,@balancedate) and @balancedate)b
		on a.����=b.localcode and a.�г�=b.mic
	)ab left join (select distinct ֤ȯ����,@balancedate as balancedate from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate) where ֤ȯ���� is not null
	)e	on ab.balancedate=e.balancedate
)abe left join
(	select balance_date,����,�г�,֤ȯ����,�ǵ���,��ʷ����
	from (select balance_date,����,�г�,֤ȯ���� from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate)
	)c left join (SELECT balancedate ��ʷ����,v.localcode,cast(left(v.changed,len(v.changed)-1) as numeric(18,4))/100 �ǵ���,v.mic
	FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE balancedate between dateadd(year,-6,@balancedate) and @balancedate
	)d on c.����=d.localcode and c.�г�=d.mic
)cd  on abe.��ʷ����=cd.��ʷ���� and abe.֤ȯ����=cd.֤ȯ����


)








GO
