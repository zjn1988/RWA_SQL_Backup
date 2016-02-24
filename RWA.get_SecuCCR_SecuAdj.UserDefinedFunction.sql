USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_SecuAdj]    Script Date: 2016/2/24 13:10:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_SecuAdj]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select Balance_Date,证券代码,代码,市场,证券名称,证券类型,上市日期
	,isnull(日均成交量,0) 日均成交量
	,isnull(收盘价,0) 收盘价

		,case 证券类型 when 'Fund' then case when right(证券名称,1)='B' then 0.7 when right(证券名称,1)='A' then 0
								else case when 证券名称 like '%沪深300%' then 0  --追踪其他指数的不为0
												when 基金投资类型 in ('货币市场性基金','债券型基金') then 0
												when 基金投资类型 in ('另类投资基金') then 0.1
											else 0.05 end end  
					when 'Stock' then case when 上市日期>Balance_Date then 0.1  --新股等情形,90%,与楠哥讨论过
											when DATEDIFF(day,最近交易日,@Balancedate)>=365 then 0.7 --已连续停牌1年以上
											when 证券名称 like '%ST%' then 0.7 --ST股票
											else (case when left(证券代码,3) in ('002','003') then 1 else 0 end --(1)中小创
													+case when isnull(流通A股,0)*isnull(收盘价,0)<1500000000 then 1 else 0 end --(2)流通市值小于15亿
													+case when DATEDIFF(day,最近交易日,@Balancedate)>=30 then 1 else 0 end --(3)已连续停牌30天以上
													+case when ROE1<0 then 1 else 0 end 
													+case when 市净率 is null then 0 else --市净率只考虑正的部分,为负的自动用以往正的代替了,待调整
													case when cast(市净率 as numeric(18,4))>cast(申万行业市净率 as numeric(18,4)) 
													and cast(市净率 as numeric(18,4))<(2*cast(申万行业市净率 as numeric(18,4)) ) then 1 else 0 end end
									)*0.05 
									+(case when ROE1<0 and ROE2<=0 then 1 else 0 end 
									+case when 市净率 is null then 1 else case when cast(市净率 as numeric(18,4))>(2*cast(申万行业市净率 as numeric(18,4))) then 1 else 0 end end
									)*0.1 end 
				 when 'CVBonds' then case when 最新债项评级 ='AAA' or 最新债项评级 is null	then 0.05 else 0.1 end 
				 when 'Bond' then case when 最新债项评级 =	'AAA' or 最新债项评级 is null	then	0
						when 最新债项评级 in ('AA+','AA')	then	0.05  else 0.1 end 
				when 'index' then 0.1 --标记为index的都是没有填写证券的，做一定处理
				else 0 end 
				+手工调整比例 
				as 定性折算比例

		,case when 市净率 is null then 0.7 else 
				case when (1-1*(0.9/cast(市净率 as numeric(18,4))))<0.7 then 0.7 
					else (1-1*(0.9/cast(市净率 as numeric(18,4)))) end end as 最大折扣
		,case when 证券类型='STOCK' then 0.25 else 0.05 end as 最小折扣

		

from	(select * from position_db.rwa.secuCCR_SecuInfo where balance_date=@BalanceDate 
)a left join (SELECT left(curvenamecn,len(curvenamecn)-4) as 申万行业,tagValueStr 申万行业市净率 
from ZX_AUDIT.zx_mkt.v_tag_info_1 where tagName = 'PE_PB_LF_SYWG_INDUSTRY_1' and balanceDate = @balancedate
) b on a.申万行业=b.申万行业








)









GO
