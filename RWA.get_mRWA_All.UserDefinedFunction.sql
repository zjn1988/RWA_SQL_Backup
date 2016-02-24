USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_All]    Script Date: 2016/2/24 11:17:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_All]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	
/*******  本表记录原始数据，同时简单匹配币种和标的代码 *******/
	
/*******  用到下列原始表:
[Position_DB].[hld].[PurePosition] --基础表
[Position_DB].[config].[AccountDeptMap1] --账户信息
[Position_DB].[xir].[acc_balance_zq2] --完整代码、利率互换和债券远期信息
[Position_DB].[mkt].[WindIssuer] --债券发行方
[Position_DB].[mkt].[xir_CompanyRating]  --发行方最新评级
[Position_DB].[mkt].[BondCurveMapping] --收益率曲线映射表   2015年4月30日起有数据
[Position_DB].[mkt].[xir_tbnd] --票面利率 
[Position_DB].[xir].[tbsi_bond]  --债券久期 
[Position_DB].[mkt].[xir_otcirswap} --利率互换付息频率
[CreditRisk].[Reference].[CounterpartyMapping] --OTC交易对手名称转换
[CreditRisk].[Counterparty].[CounterpartyBasicInfo] --OTC交易对手内部评级
[zx_audit].[zx_mkt].[v_getCurveIssuerInfo] --股票上市公司
[Audit_Bak].[RM_RUN].[Report_Global_Limit] --期权delta信息

*******/

/** 中文字段是自己创建的 **/

	
/*** RWA计算范围：1-SVaR;2-标准法;0-不计算 ***/
select *
,(case 
	when QUANTITY=PresentValue_CNY  then 2        --以账面价值计价的用标准法
	when UnderlyingMarket='China_Other' then 2  --除上海深圳银行间以外的市场,但没法匹配代码因此用标准法
	when (SECUCATEGORY in ('Bond','FwdBond','OverNight')
			and ((CurveName is NULL)or (标的发行方 is null) 
			or (MK_Duration is NULL) or (MK_DURATION=0))) then 2 --债券类缺少曲线、发行人或久期，或久期为0的用标准法
	when ((secucategory='ETF' or secucategory='Fund') and (fundtype is null) or fundtype='货币市场型基金') then 2
	else (case when InVaRLimit=1 then 1 --其余属于VaR限额范围内的部分用VaR模型计算
				when (subaccid='DKTR0401'and secucategory in ('Bond','FwdBond')) then 1
		else (case 
			/* 用标准法计算*/ 
			when DeptId = 'DZSP' then 2-- 大宗商品用标准法
			when DeptId = 'GSYW' then 2-- 公司业务用标准法
			when DeptId = 'ZJYY' then 2--资金运营部DX定增、JJ基金、XG新股三个账户用标准法
			when AccId  = 'ZJBZJJ' then 2 --证金部种子基金
			when subaccid = 'YSPXSBZY' then 2  --股衍新三板自营
			when subaccid = 'YSPXSBZS' then 2  --股衍新三板做市
			else 0 end) 
		end)
end) as RWA有效性--

from
(
	select 
	BALANCE_DATE
	,DeptID
	,AccId
	,SubAccId

	/*** 业务信息 ***/

	,SECUCATEGORY
	,SECUCODE
	,SECUMARKET
	,CONVERT(varchar(10), SettleDay , 111) as SettleDay   --仅适用于利率互换和债券远期
	,Pay_Freq  --仅适用于利率互换
	,(case when secucategory='SWAP' then FixedRate 
		when (secucategory='Bond' or secucategory='FwdBond'or secucategory='OverNight') then [B_Coupon] 
		else NULL end) as 固定利率
	,quantity
	,ccy
	,presentvalue * (case ccy 
	when 'HKD' then (SELECT [MIDDLEPRICE] FROM [Position_DB].[mkt].[wind_fxRate] where balance_date=@BalanceDate and CODE='HKDCNY')
	when 'USD' then (SELECT [MIDDLEPRICE] FROM [Position_DB].[mkt].[wind_fxRate] where balance_date=@BalanceDate and CODE='USDCNY')
	when 'CNY' then 1 else 0 end) as PresentValue_CNY  --汇率为0是错误，需要检查
	--,PresentValue
	,Notional  --仅适用于利率互换和债券远期，目前没有外币交易
	,DV01  --仅适用于利率互换，目前没有外币交易
	,counterparter
	,CounterpartyName  --仅适用于利率互换和债券远期
	,内评等级  --仅适用于利率互换和债券远期
	,InnerRating

	/***  标的资产信息  ***/

	,Underlying
	,UnderlyingMarket
	,(case when (SECUCATEGORY='FwdBond' or SECUCATEGORY='SWAP') then fullcode 
			when ((SECUCATEGORY='Bond'or SECUCATEGORY='OVERNIGHT') and FullCode<>null) then FullCode
			when ((SECUCATEGORY='ETF'or SECUCATEGORY='FUND') and 基金万得代码<>null) then 基金万得代码
			else 
			(case when Underlying ='HSHZ300' then '000300.SH'   --调整沪深300格式
				when SECUCATEGORY='CommodityFuture' then (case left(secucode,2) --其他商品期货做沪深300处理
					when 'IH' then '000016.SH' when'IC' then '000905.SH'else '000300.SH'end)   
				else (cast(Underlying as varchar(15))+'.'+(case UnderlyingMarket 
																	when 'China_ShangHai' then 'SH'
																	when 'China_ShenZhen' then 'SZ' 
																	when 'China_InterBank'then 'IB' 
																	when 'XSHGK' then 'HK'
																	when 'China_FinancialFuture' then 'CFE'
																	when 'China_FutureExchange' then 'SHF'
																	else ''
																	end))end)end)as 标的代码  --票面利率
	,MK_Duration   
	,B_MTR_Date
	,(case when secucategory='Equity' then 股票上市公司 
	else (case when curvename is null then null else ISSUERNAME end)end) as 标的发行方  --仅适用于债券和股票标的
	,GRADE  --仅适用于债券，取数日最新外部评级
	, 'NULL' as 发行人内评等级
	,CurveName  --仅适用于债券
	,[dollordelta1%]
	,fundtype
	,InVaRLimit
	,inCompany


		
	from	
	(
		select basebie.*,fund.基金万得代码,fund.fundtype
		from
		(
			select basebi.*,equity.*		
			from
			(	
				select baseb.balance_date,baseb.subaccid,baseb.accid,baseb.deptid,baseb.invarlimit,inCompany
						,baseb.SECUCODE,baseb.SECUMARKET,baseb.SECUCATEGORY,baseb.underlying
						,baseb.UnderlyingMarket,baseb.ccy,baseb.quantity,baseb.PresentValue
						,baseb.[SECUNAME],baseb.[ISSUERNAME],baseb.GRADE,baseb.CurveName
						,iOTC.FullCode,iOTC.SettleDay,iOTC.Counterparter,iOTC.CounterpartyName
						,iOTC.Notional,iOTC.DV01,iOTC.FixedRate,iOTC.PAY_FREQ,iOTC.内评等级,InnerRating
						,baseb.B_COUPON,baseb.MK_Duration,baseb.B_MTR_Date
				from 
				(
					select base.balance_date,base.subaccid,base.accid,base.deptid,base.invarlimit
						,base.SECUCODE,base.SECUMARKET,base.SECUCATEGORY,base.underlying,base.UnderlyingMarket
						,base.ccy,base.quantity,base.PresentValue,bond.B_Coupon,bond.MK_Duration,inCompany
						,bond.[SECUNAME],bond.[ISSUERNAME],bond.GRADE,bond.CurveName,base.fullcode
						,bond.B_MTR_Date
					from 
					(
						select base12.balance_date,base12.subaccid,base12.accid,base12.deptid,base12.invarlimit
							,base12.SECUCODE,base12.SECUMARKET,base12.SECUCATEGORY,base12.underlying,inCompany
							,base12.UnderlyingMarket,base12.ccy,base12.quantity,base12.PresentValue,base3.FullCode
						from
						(
							select base1.balance_date,base2.subaccid
								,substring(base1.Account,1,patindex('%;%',base1.Account)-1) as AccId
								,base1.dept as DeptId	,base2.invarlimit
								,base1.SECUCODE,base1.SECUMARKET,base1.SECUCATEGORY,base1.underlying,inCompany
								,base1.UnderlyingMarket,base1.ccy,base1.quantity,base1.PresentValue
							from 
							(
								select balance_date,account,dept,SECUCODE,SECUMARKET
								,rtrim(SECUCATEGORY) as secucategory,underlying,UnderlyingMarket,ccy
								,sum(quantity) as quantity,sum(PresentValue) as PresentValue --处理正负持仓分条记录问题
								from [Position_DB].[hld].[PurePosition] --基础表pureposition
								where [BALANCE_DATE] = @BalanceDate
								group by balance_date,account,dept,SECUCODE,SECUMARKET,SECUCATEGORY,underlying,UnderlyingMarket,ccy
							)as base1  
							left join 
							/*账户信息*/
							(
								select subaccid,accid,deptid,invarlimit,inCompany
								from [Position_DB].[config].[AccountDeptMap1]  --账户映射表
							)as base2  
							on substring(base1.Account,patindex('%;%',base1.Account)+1,len(base1.Account))=base2.SubAccId
							where 
								PresentValue<>0
									 
								/* 非境内账户或非境内资产 */
								and (Base2.InCompany=1 
									or base2.subaccid='DKTR0401' 
									or base2.subaccid='ZYBH2701')--属于公司内部账户,处理穿透的资产，不含子公司
								and SubAccId<>'Dacheng' --海外基金穿透后的境内资产,目前数据不准
								and base2.AccId <> 'BX'--巴西
								and base2.subaccid <> 'YSPKJJY' --股衍部跨境套利单纯境内信息不全

								/* 另有计算*/
								and base2.AccId <> 'SWAP' --收益互换
								and base2.SubAccId <> 'ZJBJNH' --收益互换
								and base2.Subaccid <> 'JYSGH2' --收益互换
								and base2.Subaccid <> 'GPZYHG' --股衍股权质押回购

								/* 已对冲风险*/
								and base2.Subaccid <> 'JYBJGR' --股衍结构化融资风险已对冲
								and base2.SubAccId <> 'YSP-CWQQ' --股衍部场外期权风险已对冲
								and base2.subaccid <> 'YSKJHH'--股衍部互换风险已对冲
								and base2.SubAccId <> 'TZGLB-SYQZC' --投资管理部收益权转出账户----->?
								and base2.Subaccid <> 'F_A002' --另类跟海外账户对冲的账户																			
									
						)as base12
						left join 
						(
							/*完整代码信息*/
							select code,FullCode 
							from position_db.xir.acc_balance_zq2 --完整代码
							where balance_date = @BalanceDate
							and department<>'外部' and notional<>0 
							group by code,fullcode
						)as base3
						on base12.Underlying=base3.code
					)as base

					left join 
					/*标的债券信息*/
					(
						select bond12.SECUCODE,bond12.[SECUNAME],bond12.[ISSUERNAME],bond12.GRADE
								,bond345.CurveName,bond345.SecuMarket,bond345.B_Coupon,bond345.MK_Duration
								,bond345.B_MTR_Date
						from
						(
							SELECT bond1.SecuCode,bond1.SecuName,bond1.ISSUERNAME,bond2.GRADE,bond1.Mkt_Type
							from
							(	
								select [SECUCODE],[SECUNAME],[ISSUERNAME]
								,(case [MKTNAME] when '上海' then 'China_ShangHai' when '深圳' then 'China_ShenZhen' 
												when '银行间债券' then 'China_InterBank' else NULL end) as Mkt_Type													
								FROM [Position_DB].[mkt].[WindIssuer] --债券发行方名称
							)as bond1      
							left join 
							(
								SELECT [COMP_NAME],[GRADE] 
								FROM [Position_DB].[mkt].[xir_CompanyRating]  --债券发行方最新评级
								where end_date in 
								(
									select max(end_date) 
									from [Position_DB].[mkt].[xir_CompanyRating] 
									group by comp_name
								)
							)as bond2      
							on bond1.ISSUERNAME=bond2.COMP_NAME
						)as bond12
						left join
						(
							select curvename,SecuCode,SecuMarket,B_coupon,MK_Duration,B_MTR_Date
							from 
							(
								select bond4.I_Code,B_Coupon,MK_Duration,B_MTR_Date
								,(case bond4.M_TYPE when 'XSHE' then 'China_ShenZhen' when 'XSHG' then 'China_ShangHai' 
												when 'X_CNBD' then 'China_InterBank' else NULL end )as Mkt_Type
								from
								(
									select I_Code,B_Coupon,M_TYPE,B_MTR_Date from [Position_DB].[mkt].[xir_tbnd] --票面利率
								)as bond4
								left join
								(
									select I_Code,MK_DURATION,M_TYPE
									from Position_DB.xir.tbsi_bond  --债券久期 
									where balance_date= @BalanceDate
								)as bond5 							
								on (bond4.I_Code=bond5.I_Code and bond4.M_TYPE=bond5.M_TYPE)
							)as bond45     
							left join
							(
								select curvename,SecuCode,SecuMarket
								from [Position_DB].[mkt].[BondCurveMapping] --债券与收益率曲线映射表
								where [balance_date] = @BalanceDate
							)as bond3     
							on (bond3.SecuCode=bond45.[I_Code] and bond3.SecuMarket=bond45.Mkt_Type)
						)as bond345     
						on (bond12.secucode=bond345.secucode and bond12.Mkt_Type=bond345.SecuMarket)
					)as bond
					on (base.Underlying = bond.SecuCode and base.UnderlyingMarket=bond.SecuMarket) --去掉secumarket会有重复

				)as baseb 
									
				
				left join
				/*利率互换和债券远期信息*/
				( 
					select iOTC12.PositionCode,iOTC12.FullCode,iOTC12.SettleDay,iOTC34.CounterpartyName--交易对手全称
					,iOTC12.Notional,iOTC12. DV01,iOTC12.FixedRate,iOTC12.PAY_FREQ ,iOTC12.Counterparter
					,(case when iOTC34.innerrating is null then 'Z-B5'  --所有评级空白或没有评级的假定为Z-B5，每次检查！！！
							when iOTC34.innerrating ='' then 'Z-B5'
							else iOTC34.innerrating end) as 内评等级
					,InnerRating
					from
					(
						select iOTC1.PositionCode,iOTC1.FullCode,iOTC1.SettleDay,iOTC1.Counterparter--交易对手全称
						,iOTC1.Notional,iOTC1. DV01,iOTC1.FixedRate,iOTC2.PAY_FREQ
						from
						(
							select positioncode,fullcode,settleday
							,notional*10000 as Notional,dv01*10000 as DV01,FixedRate/100 as FixedRate
							,Counterparter
							from position_db.xir.acc_balance_zq2 -- 利率互换和债券远期的完整代码、到期日及交易对手名称
							where balance_date = @BalanceDate
							and department<>'外部' and notional<>0 
							and (tradetype='远期' or tradetype='利率互换') 
						)as iOTC1     
						left join
						(
							select I_Code,PAY_FREQ
							from Position_DB.mkt.xir_otcirswap --利率互换付息频率
							where MATER_DATE > @BalanceDate
						)as iOTC2   
						on iOTC1.positioncode=iOTC2.I_CODE
					)as iOTC12
					left join
					(
						select iOTC3.OuterAlias,iOTC4.CounterpartyName,iOTC4.InnerRating
						from 
						(
							select OuterAlias,InternalName
							from [CreditRisk].[Reference].[CounterpartyMapping] 	--OTC交易对手名称转换
						)as iOTC3
						left join 
						(
							select CounterpartyName,InnerRating 
							from [CreditRisk].[Counterparty].[CounterpartyBasicInfo] --OTC交易对手内部评级
						)as iOTC4
						on iOTC3.InternalName=iOTC4.CounterpartyName
					)as iOTC34
					on iOTC12.Counterparter=iOTC34.OuterAlias collate Chinese_PRC_CI_AS_WS  --不区分（和( 不然有重复
				)as iOTC
				on baseb.secucode=iOTC.PositionCode
				--where 
				--/*去掉内部合约*/
				--(Counterparter is null or (	Counterparter not like '%中信证券%' and Counterparter not like '%CSI%'))
			)as basebi
						
			left join
			/*股票信息*/
			(
				select localCode 股票代码,issuerName 股票上市公司 
				from zx_audit.zx_mkt.v_getCurveIssuerInfo --股票上市公司
			) as equity
			on basebi.underlying=[equity].[股票代码]
		)as basebie

		left join
		(
			select underlying, underlyingmarket,基金万得代码,fundtype
			from
			( 
				select *
					,case when fund2.windcode is null then underlying+'.OF' else fund2.windcode end as 基金万得代码 
				from
				(
					select underlying, underlyingmarket
					,(underlying+(case underlyingmarket when 'China_Shanghai'then '.SH' else '.SZ'end)) 原始基金代码
					from position_db.hld.pureposition
					where balance_date =@BalanceDate 
					and (secucategory='ETF' or secucategory='Fund')
					and (underlyingmarket='China_Shanghai' or underlyingmarket='China_Shenzhen')
				)as fund1
				left join
				(
					select distinct v.windCode 
					from ZX_AUDIT.zx_mkt.v_tag_info v 
					where v.tagName = 'FUNDTYPE' 
					and v.dataSetId in (14,17,27) --14和17代表场内基金，27代表场外基金
					and v.balanceDate = @BalanceDate
					and v.tagvaluestr<>'股票型分级子基金' 
				)as fund2
				on fund1.原始基金代码=fund2.windCode
			) as fund12
			left join 
			(
				select v.windCode,v.tagValueStr fundType 
				from ZX_AUDIT.zx_mkt.v_tag_info v 
				where v.tagName = 'FUNDTYPE' 
				and v.dataSetId in (14,17,27) --14和17代表场内基金，27代表场外基金
				and v.balanceDate = @BalanceDate
				and v.tagvaluestr<>'股票型分级子基金'
			) as fund3
			on fund12.基金万得代码=fund3.windCode
			group by underlying, UnderlyingMarket,原始基金代码,基金万得代码,fund3.windCode,fundtype
		)as fund
		on (basebie.underlying=fund.underlying and basebie.underlyingmarket=fund.underlyingmarket)
	)as basebief		

	left join
		/*期权信息*/
	(
		SELECT substring(positionname,patindex('%_%',positionname)+1,7) as code,value as 'dollordelta1%'
		FROM [Audit_Bak].[RM_RUN].[Report_Global_Limit] --期权delta信息
		WHERE  balance_date =convert (varchar(10),@BalanceDate ,112)
		AND indicator = 'Equity Dollar Delta 1%'
		AND assettype = 'EQUITYOPTION' 
	)as option1
	on basebief.secucode=('1'+option1.code)
			
) as mRWA


)












GO
