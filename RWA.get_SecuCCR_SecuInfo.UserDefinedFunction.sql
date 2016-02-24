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
-- Description:	<֤ȯ������ҵ��ĵ�Ѻȯ��Ϣ>
�õ����º�����

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
	,֤ȯ����
	,b.����
	,case when ֤ȯ���� is null then 'OF' else b.�г� end as �г�
	,case when ֤ȯ���� is null then 'FUND' else ֤ȯ���� end as ֤ȯ����
	,case when ֤ȯ���� is NULL then �������� else ֤ȯ���� end as ֤ȯ����
	,����Ͷ������
	,��������
	,�վ��ɽ���
	,��ͨA��
	,���̼�
	,isnull(���������,@balancedate) ���������
	,�о���
	,������ҵ
	,����ծ������
	,0 as ROE1
	,0 as ROE2
	,0 as �ֹ���������
from
(													
	select 
		distinct ֤ȯ���� as ֤ȯ����,left(֤ȯ����,patindex('%.%',֤ȯ����)-1) as ����
		,case right(֤ȯ����,2) when 'SH' then 'XSHG' when 'SZ' then 'XSHE' when 'IB' then 'IB' 
								when 'IC' then 'NEEQ' when 'OF' then 'OF' else NULL end as �г�,sum(��ֵ) as ��ֵ
	from(	
		select 
			case when ֤ȯ���� is null then '000300.SH' else ֤ȯ���� end as ֤ȯ����
			,sum(֤ȯ��ֵ)as ��ֵ 
		from position_db.rwa.get_TRS_ContractDtl(@balancedate) group by ֤ȯ����
		union all select ֤ȯ����,sum(֤ȯ��ֵ)as ��ֵ from position_db.rwa.get_RZRQ_Dtl(@balancedate)  group by ֤ȯ����
		union all select ��Ѻȯ����,sum(��Ѻȯ��ֵ)as ��ֵ from position_db.rwa.get_CR_STOCKPDG_Cltr(@balancedate) group by ��Ѻȯ����
		union all select ��Ѻȯ����,sum(��ѺȨ��ֵ)as ��ֵ from position_db.rwa.get_AGREPO(@balancedate)  group by ��Ѻȯ����
	)a 
	where ��ֵ<>0 
	group by ֤ȯ����  
)b 
left join 
(
	select localcode,mic ,curveNameCn ֤ȯ����,curvePropertyDesc ֤ȯ����
	FROM zx_audit.[ZX_MKT].[v_getEquityType]  --����Ҫ�����ֶ�
)c 	
on b.����=c.localcode and b.�г�=c.mic
left join 
(
	SELECT	v.localcode,v.mic ,v.fundType ����Ͷ������,curveNameCn �������� 
	FROM zx_audit.[ZX_MKT].[v_getFundType] v	
	WHERE balancedate = @balancedate  
)e 
on b.����=e.localcode and b.�г�=e.mic
left join 
( 
	SELECT  v.localcode,v.mic
	,cast(cast(case v.issueDate when '-' then '19000101' else v.issueDate end as varchar)as datetime) ��������
	FROM [zx_audit].[ZX_MKT].[v_getEquityIssueDate] v  --����Ҫ�����ֶ�
)g 
on b.����=g.localcode and b.�г�=g.mic
left join 
( 	
	select localcode,mic,AvgVolume_30D �վ��ɽ��� 
	from  [zx_audit].[ZX_MKT].[v_getEquityAvgVolume_30D] 
	where balanceDate = @balancedate 
)i 
on b.����=i.localcode and b.�г�=i.mic
left join 
( 
	SELECT	v.localcode, v.mic,v.liquidity ��ͨA�� 
	FROM [zx_audit].[ZX_MKT].[v_getStockLiquidity] v
	where balanceDate = @balancedate  
)k 
on b.����=k.localCode and b.�г�=k.mic  
left join 
( 	
	SELECT  code,mic,closePrice ���̼� 
	FROM [zx_audit].[ZX_MKT].[v_getStockClosePrice]
	WHERE dailyDate = @balancedate 
)m 
on b.����=m.code and b.�г�=m.mic
left join 
(  
	SELECT	v.localcode,v.mic
	,cast(cast(v.lastradeDay as varchar)as date) ���������
	FROM zx_audit.[ZX_MKT].[v_getEquityLastradeDay] v  
	WHERE balancedate = @balancedate
) o 
on b.����=o.localCode and b.�г�=o.mic
left join 
(	
	SELECT	v.localcode,v.val_pb_lf �о���,v.mic 
	FROM zx_audit.zx_mkt.[v_getEquityValPbLf] v
	WHERE balanceDate = @balancedate 
)q 
on b.����=q.localCode and b.�г�=q.mic
left join 
(
	SELECT localcode ,v.sywg_industry1 ������ҵ,v.mic 
	FROM zx_audit.[ZX_MKT].[v_getStockSYWG_Industry1] v  --����Ҫ�����ֶ�
)s
on b.����=s.localCode and b.�г�=s.mic
left join 
(
	select localCode,bondLatestRateCredit ����ծ������,mic 
	from ZX_AUDIT.zx_mkt.[v_getBondLatestRateCredit]
)u 
on b.����=u.localcode and b.�г�=u.mic


				


)






GO
