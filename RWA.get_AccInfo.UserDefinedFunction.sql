USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_AccInfo]    Script Date: 2016/2/24 11:14:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-03,,>
-- Description:	<获得市账户信息,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_AccInfo]
( 

@Balancedate DateTime

)

RETURNS TABLE 
AS
RETURN 
(

select *,case category
when 	'公司-计财部'	then	'1001'
when '公司-股销' then '1002'
when 	'公司-其他'	then	'1004'
when 	'公司-投资管理部'	then	'1003'
when 	'股衍-ETF做市'	then	'0304'
when 	'股衍-股票质押回购'	then	'0301'
when 	'股衍-基本面策略'	then	'0306'
when 	'股衍-境内TRS'	then	'0303'
when 	'股衍-量化策略'	then	'0307'
when 	'股衍-期权做市'	then	'0305'
when 	'股衍-其他'	then	'0309'
when 	'股衍-新三板'	then	'0308'
when 	'股衍-约定购回'	then	'0302'
when 	'固收-财富管理'	then	'0102'
when 	'固收-夹层投资'	then	'0104'
when 	'固收-交易'	then	'0101'
when 	'固收-销售'	then	'0103'
when 	'权益投资-定增'	then	'0501'
when    '权益投资-特定投资' then '0501'  --从2015年12月31日起新增
when 	'权益投资-股票交易'	then	'0502'  --从2016年1月起从“交易”改成“权益投资”
when    '权益投资-应急'	then	'0503'
when 	'另类-FOF'	then	'0401'
when 	'另类-MOM'	then	'0402'
when 	'另类-量化策略'	then	'0403'
when 	'另类-期权自营'	then	'0404'
when 	'另类-应急'	then	'0405'
when 	'新三板-新三板'	then	'0601'
--when 	'应急-权益投资'	then	'0601'
--when 	'应急-另类'	then	'0602'
when 	'证金-股权投资'	then	'0205'
when 	'证金-境内TRS'	then	'0202'
when 	'证金-融券池'	then	'0203'
when 	'证金-融资融券'	then	'0201'
when 	'证金-种子基金'	then	'0206'
when   '证金-流动性管理' then '0204'
when 	'资金-打新'	then	'0901'
when 	'资金-流动'	then	'0902'
when 	'资金-其他'	then	'0903'
when 	'资金-资配'	then	'0904'
when    '资金-负债管理户' then '0905'
when '大宗' then '0700'
else '9999' end	 组合代码
,case deptname 
when 	'固收'	then	'0100'
when 	'证金'	then	'0200'
when 	'股衍'	then	'0300'
when 	'另类'	then	'0400'
when 	'权益投资'	then	'0500'
when 	'新三板'	then	'0600' --2016年之前是"应急账户" 统一改为"新三板",不再区分应急
when 	'大宗'	then	'0700'
when 	'资金'	then	'0900'
when 	'公司'	then	'1000'
else '9999'end 部门代码
,'0000' as 公司代码
from(select subaccid,invarlimit,incompany,subaccname
	,case when deptname='大宗' then deptname else deptname+'-'+category end category
	,deptname
from(select subaccid,invarlimit,incompany,subaccname
	,case when subaccid='ZJBZJJ'then '种子基金' 
		when subaccid in ('YYB-JJ','YYB-DX') then '其他' 
		when subaccid in ('ZYBH2701','DKTR0401') then '交易'
		when category='JYSDEV' then '其他'
		--when deptname='交易'and category='应急' then '交易'
		--when deptname='另类'and category='应急' then '另类'
		when deptname='GSYW' and subaccid not in ('TZGLB','JCB') then '其他'
		when deptname='DZSP' then '大宗'
		when category in ('MOMCTA','MOM多空') then 'MOM'
		when category ='JCB' then '计财部'
		when category ='TZGLB' then '投资管理部'
		when category ='大宗交易' then '股销'
		else category end as category
	,case when subaccid='ZJBZJJ'then '证金'
		when subaccid in ('YYB-JJ','YYB-DX') then '资金'
		when subaccid in ('ZYBH2701','DKTR0401') then '固收' 
		when category='JYSDEV' then '股衍' 
		when deptname='夹层投资' then '固收'
		when deptname='DZSP' then '大宗'
		when deptname='GSYW' then '公司'
		--when category='应急' then '应急'
		when deptname='股销' then '公司'
		else deptname end as deptname

from
(
	select subaccid,invarlimit,inCompany
	,case when stratname is null then (case when subaccname is null then subaccid else subaccname end) else stratname end as subaccname
	,case when category is null then (case when inneraccname is null or len(inneraccname)=0 then accid else inneraccname end) else category end as category
	,case when Dept is null then (case when deptname is null or len(DeptName)=0then deptid else deptname end) else dept end as deptname

	from
	(
		select a.subaccid,a.accid,deptid,invarlimit,incompany,stratname,category,dept,subaccname,inneraccname,deptname
		from
		(
			select distinct right(Account,len(account)-patindex('%;%',Account)) as SubAccId
			,left(Account,patindex('%;%',Account)-1) as AccId
			,dept as DeptId 
			from [Position_DB].[hld].[PurePosition]where [BALANCE_DATE] = @BalanceDate
		)a
		left join
		(
			select subaccid,invarlimit,inCompany	from [Position_DB].[config].[AccountDeptMap1]
		)b
		on a.Subaccid=b.subaccid
		left join
		(
			SELECT  distinct accid,stratname,category,dept
			FROM    MarketRisk.Report.fn_market_calculateAccountPnlSeriesQsQuickCNY(@Balancedate,@Balancedate,'*')
			where category<>'TRS'
		) as equity
		on a.subaccid=equity.accid
		left join position_db.config.accountdeptmap_zq  fi
		on a.subaccid=fi.subaccid
	)totalefi

	where (InCompany=1 or subaccid in ('DKTR0401' ,'ZYBH2701'))--属于公司内部账户,处理穿透的资产，不含子公司
	and SubAccId<>'Dacheng' --海外基金穿透后的境内资产,目前数据不准
	and AccId <> 'BX'--巴西
	and subaccid <> 'YSPKJJY' --股衍部跨境套利单纯境内信息不全
	and subaccid <> 'YSPHGTCS' --股衍部沪港通测试户，量小且杂，市场组也不算

	/* 另有计算*/
	and AccId <> 'SWAP' --收益互换
	and SubAccId <> 'ZJBJNH' --收益互换
	and Subaccid <> 'JYSGH2' --收益互换
	and Subaccid <> 'GPZYHG' --股衍股权质押回购

	/* 已对冲风险*/
	and Subaccid <> 'JYBJGR' --股衍结构化融资风险已对冲
	and SubAccId <> 'YSP-CWQQ' --股衍部场外期权风险已对冲
	and subaccid <> 'YSKJHH'--股衍部互换风险已对冲
	and SubAccId <> 'TZGLB-SYQZC' --投资管理部收益权转出账户----->?
	and Subaccid <> 'F_A002' --另类跟海外账户对冲的账户
	and Subaccid <> 'YSPET2' --另一端在CSI的RQFII的ETF对冲		
)c)d)e
   
)





GO
