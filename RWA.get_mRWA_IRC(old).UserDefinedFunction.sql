USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_IRC(old)]    Script Date: 2016/2/24 11:17:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-16,更新于2015-12-02>
-- Description:	<获得市场风险计算新增风险的持仓数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_IRC(old)]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


select 
	@BalanceDate as Balance_Date
	,IRCType,RiskFactor,Issuer,RatingOrder,SysFactor,IdoFactor,MK_Duration,DurationOrder
	,(case IRCType when 'Bond' then (case RatingOrder
	when 	1	then ( case DurationOrder when	1	then	 0.0008 	
			when	2	then	 0.0007 	
			when	3	then	 0.0011 	
			when	4	then	 0.0015 	
			when	5	then	 0.0019 	
			when	6	then	 0.0034 	
			else			 0.0049 	end)
	when 	2	then ( case DurationOrder when	1	then	 0.0015 	
			when	2	then	 0.0017 	
			when	3	then	 0.0023 	
			when	4	then	 0.0032 	
			when	5	then	 0.0040 	
			when	6	then	 0.0053 	
			else		 0.0066 	end)
	when 	3	then ( case DurationOrder when	1	then	 0.0019 	
			when	2	then	 0.0022 	
			when	3	then	 0.0031 	
			when	4	then	 0.0042 	
			when	5	then	 0.0052 	
			when	6	then	 0.0069 	
			else		 0.0082 	end)
	when 	4	then ( case DurationOrder when	1	then	 0.0034 	
			when	2	then	 0.0041 	
			when	3	then	 0.0056 	
			when	4	then	 0.0075 	
			when	5	then	 0.0093 	
			when	6	then	 0.0119 	
			else		 0.0136 	end)
	when 	5	then ( case DurationOrder when	1	then	 0.0106 	
			when	2	then	 0.0122 	
			when	3	then	 0.0155 	
			when	4	then	 0.0189 	
			when	5	then	 0.0223 	
			when	6	then	 0.0269 	
			else		 0.0290 	end)
	when 	6	then ( case DurationOrder when	1	then	 0.0138 	
			when	2	then	 0.0164 	
			when	3	then	 0.0220 	
			when	4	then	 0.0273 	
			when	5	then	 0.0324 	
			when	6	then	 0.0380 	
			else		 0.0404 	end)
			else ( case DurationOrder when	1	then	 0.0918 	
			when	2	then	 0.0864 	
			when	3	then	 0.0946 	
			when	4	then	 0.1003 	
			when	5	then	 0.1046 	
			when	6	then	 0.1061 	
			else		 0.1181 	end)end)else NULL end
	)as OriCDS
	,公司总计,固定收益部,固收交易,固收财富管理,固收销售,夹层投资部,资金运营部,权益投资部,股票交易,权益应急
	,股衍业务线,另类投资业务线,另类量化,另类应急,证券金融业务线,证金券池,证金股权及其他,其他


from
(
	select

	IRCType
	,a.标的代码 as RiskFactor
	,MK_Duration

	,(case IRCType when 'Bond' then (case 
	when	MK_Duration	<	1 	then	1
	when	MK_Duration	<	2 	then	2
	when	MK_Duration	<	3 	then	3
	when	MK_Duration	<	4 	then	4
	when	MK_Duration	<	5 	then	5
	when	MK_Duration	<	7 	then	6
	else 7  end) else NULL end 
	)as DurationOrder

	,标的发行方 as Issuer

	,(case 评级补全
	when	'Z-A1'	then	1 --'Aaa'
	when	'Z-A2'	then	2 --'Aa'
	when	'Z-A3'	then	2 --'Aa'
	when	'Z-A4'	then	3 --'A'
	when	'Z-A5'	then	3 --'A'
	when	'Z-B1'	then	3 --'A'
	when	'Z-B2'	then	4 --'Baa'
	when	'Z-B3'	then	4 --'Baa'
	when	'Z-B4'	then	4 --'Baa'
	when	'Z-B5'	then	4 --'Baa'
	when	'Z-C1'	then	5 --'Ba'
	when	'Z-C2'	then	5 --'Ba'
	when	'Z-C3'	then	5 --'Ba'
	when	'Z-D'	then	6 --'B'
	else 7 end	--'Caa-C' 
	)as RatingOrder

	,(case 评级补全
	when	'Z-A1'	then	 0.28571 
	when	'Z-A2'	then	 0.28096 
	when	'Z-A3'	then	 0.28096 
	when	'Z-A4'	then	 0.27539 
	when	'Z-A5'	then	 0.27539 
	when	'Z-B1'	then	 0.27539 
	when	'Z-B2'	then	 0.22997 
	when	'Z-B3'	then	 0.22997 
	when	'Z-B4'	then	 0.22997 
	when	'Z-B5'	then	 0.22997 
	when	'Z-C1'	then	 0.22108 
	when	'Z-C2'	then	 0.22108 
	when	'Z-C3'	then	 0.22108 
	when	'Z-D'	then	 0.14966 
	else 0.14400 end
	)as SysFactor

	,(case 评级补全
	when	'Z-A1'	then	 0.95831 
	when	'Z-A2'	then	 0.95972 
	when	'Z-A3'	then	 0.95972 
	when	'Z-A4'	then	 0.96133 
	when	'Z-A5'	then	 0.96133 
	when	'Z-B1'	then	 0.96133 
	when	'Z-B2'	then	 0.97320 
	when	'Z-B3'	then	 0.97320 
	when	'Z-B4'	then	 0.97320 
	when	'Z-B5'	then	 0.97320 
	when	'Z-C1'	then	 0.97526 
	when	'Z-C2'	then	 0.97526 
	when	'Z-C3'	then	 0.97526 
	when	'Z-D'	then	 0.98874 
	else  0.98958 end
	)as IdoFactor

	,sum(MtM) as '公司总计'
	,sum(case when 组合 in( '固收交易', '固收销售','固收财富管理') then MtM else 0 end) as '固定收益部'
	,sum(case 组合 when '固收交易' then MtM else 0 end) as '固收交易'
	,sum(case 组合 when '固收财富管理' then MtM else 0 end) as '固收财富管理'
	,sum(case 组合 when '固收销售' then MtM else 0 end) as '固收销售'
	,sum(case 组合 when '夹层投资部' then MtM else 0 end) as '夹层投资部'
	,sum(case 组合 when '资金运营部' then MtM  else 0 end) as '资金运营部'
	,sum(case when 组合 in( '权益应急','股票交易') then MtM else 0 end) as '权益投资部'
	,sum(case when 组合 ='权益应急'then MtM else 0 end) as '权益应急'
	,sum(case when 组合 ='股票交易'then MtM else 0 end) as '股票交易'
	,sum(case 组合 when '股衍业务线' then MtM else 0 end) as '股衍业务线'
	,sum(case when 组合 in('另类量化','另类应急') then MtM else 0 end) as '另类投资业务线'
	,sum(case when 组合 ='另类量化' then MtM else 0 end) as '另类量化'
	,sum(case when 组合 ='另类应急' then MtM else 0 end) as '另类应急'
	,sum(case when 组合 in('证金券池','证金股权及其他') then MtM else 0 end) as '证券金融业务线'
	,sum(case 组合 when '证金券池' then MtM else 0 end) as '证金券池'
	,sum(case 组合 when '证金股权及其他' then MtM else 0 end) as '证金股权及其他'
	,sum(case 组合 when '其他' then MtM else 0 end) as  '其他'

	from
	(
		select 	标的代码

			,(case AccId when 'FIJY' then '固收交易' when 'FIZJ' then '固收财富管理'
			when 'FIXS' then '固收销售'	when 'JYSDEV' then '股衍业务线' 
			else (case when DeptId= 'JCTZ' then  '夹层投资部' when DeptId = 'ZJYY' then '资金运营部'
			when SubAccId = 'ZJBRQC' then '证金券池' when (DeptID='ZQJR'and SubAccId<>'ZJBRQC') then '证金股权及其他'
			when (AccId='JYSSTOCK'and SubAccId in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '权益应急'
			when (AccId='JYSSTOCK'and SubAccId not in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '股票交易'
			when (AccId='Quant'and SubAccId='LLTZ-YYZC')then '另类应急'
			when (AccId='Quant'and SubAccId<>'LLTZ-YYZC') then  '另类量化'
			else '其他' end) end) as 组合

			, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end
			) as MtM

			,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end
			) as 'IRCType'

		from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
			and RWA有效性=1 
			and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
			and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		group by 标的代码,SECUCATEGORY,DeptID,AccID,SubAccId
	) as a
	left join 
	( 
		select 标的代码
			,标的发行方
			,Grade
			,(case when 标的发行方 is NULL then 'Z-B5' --补充股票发行人!!!
			when 标的发行方 like '%财政部%' then 'Z-A1' 
			when 标的发行方 like '%人民政府%'then 'Z-A1'
			when 标的发行方 like '%农业发展银行%'then 'Z-A1'
			when 标的发行方 like '%进出口银行%'then 'Z-A1'  --其余城投平台不作特殊处理
			else (case when  Grade is NULL then 'Z-B5' 
						when	Grade='AAA+'	then	'Z-A1'
						when	Grade='AAA'	then	'Z-A2'
						when	Grade='AAA-'	then	'Z-A4'
						when	Grade='AA+'	then	'Z-A5'
						when	Grade='AA'	then	'Z-B2'
						when	Grade='AA-'	then	'Z-B4'
						when	Grade='A+'	then	'Z-C1'
						when	Grade='A'	then	'Z-C2'
						when	Grade='A-'	then	'Z-C3'
						else 'Z-D' end) end
			)as '评级补全'
			,MK_Duration
	
		from [Position_DB].[RWA].[mRWA_All] where Balance_date=@BalanceDate
			and RWA有效性=1 
			and Underlying not in ('000300.SH','000016.SH','000905.SH')  --指数不计算IRC
			and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		group by 标的代码,标的发行方,GRADE,MK_Duration
	)as b
	on a.标的代码=b.标的代码
		group by a.标的代码, a.IRCType, b.标的发行方, b.评级补全,MK_Duration

)as ab
where (公司总计<>0 or 固收交易<>0 or 固收财富管理<>0 or 固收销售<>0
or 夹层投资部<>0 or 资金运营部<>0 or 权益投资部<>0 or 权益应急<>0 or 股票交易<>0 
or 股衍业务线<>0 or 另类量化<>0 or 另类应急<>0 or 另类投资业务线<>0 
or 证金券池<>0 or 证金股权及其他<>0 or 其他<>0 )


)




GO
