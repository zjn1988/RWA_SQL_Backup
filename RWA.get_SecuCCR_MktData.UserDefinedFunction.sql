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


select balance_date,abe.历史日期,abe.证券代码
	,case when 涨跌幅 is null or 涨跌幅=0 then (SELECT cast(left(v.changed,len(v.changed)-1) as numeric(18,4))/100	
												FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE v.localCode='000300' and balanceDate=abe.历史日期)
			else 涨跌幅 end 涨跌幅

from(	select 历史日期,证券代码
	from( select distinct 历史日期,@balancedate as balancedate
		from (select 代码,市场 from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate))a left join (SELECT balancedate 历史日期,v.localcode,v.mic
		FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE balancedate between dateadd(year,-6,@balancedate) and @balancedate)b
		on a.代码=b.localcode and a.市场=b.mic
	)ab left join (select distinct 证券代码,@balancedate as balancedate from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate) where 证券代码 is not null
	)e	on ab.balancedate=e.balancedate
)abe left join
(	select balance_date,代码,市场,证券代码,涨跌幅,历史日期
	from (select balance_date,代码,市场,证券代码 from Position_DB.rwa.get_SecuCCR_SecuInfo(@balancedate)
	)c left join (SELECT balancedate 历史日期,v.localcode,cast(left(v.changed,len(v.changed)-1) as numeric(18,4))/100 涨跌幅,v.mic
	FROM zx_audit.[ZX_MKT].[v_getEquityChanged] v WHERE balancedate between dateadd(year,-6,@balancedate) and @balancedate
	)d on c.代码=d.localcode and c.市场=d.mic
)cd  on abe.历史日期=cd.历史日期 and abe.证券代码=cd.证券代码


)








GO
