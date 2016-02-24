USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_SecuInfo]    Script Date: 2016/2/24 13:10:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/*=============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-10,>
-- Description:	<证券融资类业务的抵押券信息>
用到如下函数：

position_db.rwa.get_TRS_ContractDtl(@balancedate)
position_db.rwa.get_RZRQ_Dtl(@balancedate)
position_db.rwa.get_CR_STOCKPDG_Cltr(@balancedate)
position_db.rwa.get_AGREPO(@balancedate)

zx_audit.[ZX_MKT].[v_getEquityType]
zx_audit.[ZX_MKT].[v_getFundType]
[zx_audit].[ZX_MKT].[v_getEquityIssueDate]
[zx_audit].[ZX_MKT].[v_getEquityAvgVolume_30D] 
[zx_audit].[ZX_MKT].[v_getStockLiquidity] 
[zx_audit].[ZX_MKT].[v_getStockClosePrice]
zx_audit.[ZX_MKT].[v_getEquityLastradeDay]
zx_audit.zx_mkt.[v_getEquityValPbLf]
zx_audit.[ZX_MKT].[v_getStockCSRC_Industry1]
ZX_AUDIT.zx_mkt.[v_getBondLatestRateCredit]

===============================================*/
CREATE FUNCTION [RWA].[get_SecuCCR_SecuInfo]
( 
	@BalanceDate DATE

	)

RETURNS TABLE 
AS
RETURN 



(



select 
	@BalanceDate Balance_Date
	,证券代码
	,b.代码
	,case when 证券类型 is null then 'OF' else b.市场 end as 市场
	,case when 证券类型 is null then 'FUND' else 证券类型 end as 证券类型
	,case when 证券名称 is NULL then 基金名称 else 证券名称 end as 证券名称
	,基金投资类型
	,上市日期
	,日均成交量
	,流通A股
	,收盘价
	,isnull(最近交易日,@balancedate) 最近交易日
	,市净率
	,申万行业
	,最新债项评级
	,0 as ROE1
	,0 as ROE2
	,0 as 手工调整比例
from
(													
	select 
		distinct 证券代码 as 证券代码,left(证券代码,patindex('%.%',证券代码)-1) as 代码
		,case right(证券代码,2) when 'SH' then 'XSHG' when 'SZ' then 'XSHE' when 'IB' then 'IB' 
								when 'IC' then 'NEEQ' when 'OF' then 'OF' else NULL end as 市场,sum(市值) as 市值
	from(	
		select 
			case when 证券代码 is null then '000300.SH' else 证券代码 end as 证券代码
			,sum(证券市值)as 市值 
		from position_db.rwa.get_TRS_ContractDtl(@balancedate) group by 证券代码
		union all select 证券代码,sum(证券市值)as 市值 from position_db.rwa.get_RZRQ_Dtl(@balancedate)  group by 证券代码
		union all select 抵押券代码,sum(抵押券市值)as 市值 from position_db.rwa.get_CR_STOCKPDG_Cltr(@balancedate) group by 抵押券代码
		union all select 抵押券代码,sum(抵押权市值)as 市值 from position_db.rwa.get_AGREPO(@balancedate)  group by 抵押券代码
	)a 
	where 市值<>0 
	group by 证券代码  
)b 
left join 
(
	select localcode,mic ,curveNameCn 证券名称,curvePropertyDesc 证券类型
	FROM zx_audit.[ZX_MKT].[v_getEquityType]  --不需要日期字段
)c 	
on b.代码=c.localcode and b.市场=c.mic
left join 
(
	SELECT	v.localcode,v.mic ,v.fundType 基金投资类型,curveNameCn 基金名称 
	FROM zx_audit.[ZX_MKT].[v_getFundType] v	
	WHERE balancedate = @balancedate  
)e 
on b.代码=e.localcode and b.市场=e.mic
left join 
( 
	SELECT  v.localcode,v.mic
	,cast(cast(case v.issueDate when '-' then '19000101' else v.issueDate end as varchar)as datetime) 上市日期
	FROM [zx_audit].[ZX_MKT].[v_getEquityIssueDate] v  --不需要日期字段
)g 
on b.代码=g.localcode and b.市场=g.mic
left join 
( 	
	select localcode,mic,AvgVolume_30D 日均成交量 
	from  [zx_audit].[ZX_MKT].[v_getEquityAvgVolume_30D] 
	where balanceDate = @balancedate 
)i 
on b.代码=i.localcode and b.市场=i.mic
left join 
( 
	SELECT	v.localcode, v.mic,v.liquidity 流通A股 
	FROM [zx_audit].[ZX_MKT].[v_getStockLiquidity] v
	where balanceDate = @balancedate  
)k 
on b.代码=k.localCode and b.市场=k.mic  
left join 
( 	
	SELECT  code,mic,closePrice 收盘价 
	FROM [zx_audit].[ZX_MKT].[v_getStockClosePrice]
	WHERE dailyDate = @balancedate 
)m 
on b.代码=m.code and b.市场=m.mic
left join 
(  
	SELECT	v.localcode,v.mic
	,cast(cast(v.lastradeDay as varchar)as date) 最近交易日
	FROM zx_audit.[ZX_MKT].[v_getEquityLastradeDay] v  
	WHERE balancedate = @balancedate
) o 
on b.代码=o.localCode and b.市场=o.mic
left join 
(	
	SELECT	v.localcode,v.val_pb_lf 市净率,v.mic 
	FROM zx_audit.zx_mkt.[v_getEquityValPbLf] v
	WHERE balanceDate = @balancedate 
)q 
on b.代码=q.localCode and b.市场=q.mic
left join 
(
	SELECT localcode ,v.sywg_industry1 申万行业,v.mic 
	FROM zx_audit.[ZX_MKT].[v_getStockSYWG_Industry1] v  --不需要日期字段
)s
on b.代码=s.localCode and b.市场=s.mic
left join 
(
	select localCode,bondLatestRateCredit 最新债项评级,mic 
	from ZX_AUDIT.zx_mkt.[v_getBondLatestRateCredit]
)u 
on b.代码=u.localcode and b.市场=u.mic


				


)






GO
