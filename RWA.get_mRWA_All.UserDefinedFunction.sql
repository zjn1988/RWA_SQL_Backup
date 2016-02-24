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
-- Description:	<����г���������,����RWA����>
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
	
/*******  �����¼ԭʼ���ݣ�ͬʱ��ƥ����ֺͱ�Ĵ��� *******/
	
/*******  �õ�����ԭʼ��:
[Position_DB].[hld].[PurePosition] --������
[Position_DB].[config].[AccountDeptMap1] --�˻���Ϣ
[Position_DB].[xir].[acc_balance_zq2] --�������롢���ʻ�����ծȯԶ����Ϣ
[Position_DB].[mkt].[WindIssuer] --ծȯ���з�
[Position_DB].[mkt].[xir_CompanyRating]  --���з���������
[Position_DB].[mkt].[BondCurveMapping] --����������ӳ���   2015��4��30����������
[Position_DB].[mkt].[xir_tbnd] --Ʊ������ 
[Position_DB].[xir].[tbsi_bond]  --ծȯ���� 
[Position_DB].[mkt].[xir_otcirswap} --���ʻ�����ϢƵ��
[CreditRisk].[Reference].[CounterpartyMapping] --OTC���׶�������ת��
[CreditRisk].[Counterparty].[CounterpartyBasicInfo] --OTC���׶����ڲ�����
[zx_audit].[zx_mkt].[v_getCurveIssuerInfo] --��Ʊ���й�˾
[Audit_Bak].[RM_RUN].[Report_Global_Limit] --��Ȩdelta��Ϣ

*******/

/** �����ֶ����Լ������� **/

	
/*** RWA���㷶Χ��1-SVaR;2-��׼��;0-������ ***/
select *
,(case 
	when QUANTITY=PresentValue_CNY  then 2        --�������ֵ�Ƽ۵��ñ�׼��
	when UnderlyingMarket='China_Other' then 2  --���Ϻ��������м�������г�,��û��ƥ���������ñ�׼��
	when (SECUCATEGORY in ('Bond','FwdBond','OverNight')
			and ((CurveName is NULL)or (��ķ��з� is null) 
			or (MK_Duration is NULL) or (MK_DURATION=0))) then 2 --ծȯ��ȱ�����ߡ������˻���ڣ������Ϊ0���ñ�׼��
	when ((secucategory='ETF' or secucategory='Fund') and (fundtype is null) or fundtype='�����г��ͻ���') then 2
	else (case when InVaRLimit=1 then 1 --��������VaR�޶Χ�ڵĲ�����VaRģ�ͼ���
				when (subaccid='DKTR0401'and secucategory in ('Bond','FwdBond')) then 1
		else (case 
			/* �ñ�׼������*/ 
			when DeptId = 'DZSP' then 2-- ������Ʒ�ñ�׼��
			when DeptId = 'GSYW' then 2-- ��˾ҵ���ñ�׼��
			when DeptId = 'ZJYY' then 2--�ʽ���Ӫ��DX������JJ����XG�¹������˻��ñ�׼��
			when AccId  = 'ZJBZJJ' then 2 --֤�����ӻ���
			when subaccid = 'YSPXSBZY' then 2  --������������Ӫ
			when subaccid = 'YSPXSBZS' then 2  --��������������
			else 0 end) 
		end)
end) as RWA��Ч��--

from
(
	select 
	BALANCE_DATE
	,DeptID
	,AccId
	,SubAccId

	/*** ҵ����Ϣ ***/

	,SECUCATEGORY
	,SECUCODE
	,SECUMARKET
	,CONVERT(varchar(10), SettleDay , 111) as SettleDay   --�����������ʻ�����ծȯԶ��
	,Pay_Freq  --�����������ʻ���
	,(case when secucategory='SWAP' then FixedRate 
		when (secucategory='Bond' or secucategory='FwdBond'or secucategory='OverNight') then [B_Coupon] 
		else NULL end) as �̶�����
	,quantity
	,ccy
	,presentvalue * (case ccy 
	when 'HKD' then (SELECT [MIDDLEPRICE] FROM [Position_DB].[mkt].[wind_fxRate] where balance_date=@BalanceDate and CODE='HKDCNY')
	when 'USD' then (SELECT [MIDDLEPRICE] FROM [Position_DB].[mkt].[wind_fxRate] where balance_date=@BalanceDate and CODE='USDCNY')
	when 'CNY' then 1 else 0 end) as PresentValue_CNY  --����Ϊ0�Ǵ�����Ҫ���
	--,PresentValue
	,Notional  --�����������ʻ�����ծȯԶ�ڣ�Ŀǰû����ҽ���
	,DV01  --�����������ʻ�����Ŀǰû����ҽ���
	,counterparter
	,CounterpartyName  --�����������ʻ�����ծȯԶ��
	,�����ȼ�  --�����������ʻ�����ծȯԶ��
	,InnerRating

	/***  ����ʲ���Ϣ  ***/

	,Underlying
	,UnderlyingMarket
	,(case when (SECUCATEGORY='FwdBond' or SECUCATEGORY='SWAP') then fullcode 
			when ((SECUCATEGORY='Bond'or SECUCATEGORY='OVERNIGHT') and FullCode<>null) then FullCode
			when ((SECUCATEGORY='ETF'or SECUCATEGORY='FUND') and ������ô���<>null) then ������ô���
			else 
			(case when Underlying ='HSHZ300' then '000300.SH'   --��������300��ʽ
				when SECUCATEGORY='CommodityFuture' then (case left(secucode,2) --������Ʒ�ڻ�������300����
					when 'IH' then '000016.SH' when'IC' then '000905.SH'else '000300.SH'end)   
				else (cast(Underlying as varchar(15))+'.'+(case UnderlyingMarket 
																	when 'China_ShangHai' then 'SH'
																	when 'China_ShenZhen' then 'SZ' 
																	when 'China_InterBank'then 'IB' 
																	when 'XSHGK' then 'HK'
																	when 'China_FinancialFuture' then 'CFE'
																	when 'China_FutureExchange' then 'SHF'
																	else ''
																	end))end)end)as ��Ĵ���  --Ʊ������
	,MK_Duration   
	,B_MTR_Date
	,(case when secucategory='Equity' then ��Ʊ���й�˾ 
	else (case when curvename is null then null else ISSUERNAME end)end) as ��ķ��з�  --��������ծȯ�͹�Ʊ���
	,GRADE  --��������ծȯ��ȡ���������ⲿ����
	, 'NULL' as �����������ȼ�
	,CurveName  --��������ծȯ
	,[dollordelta1%]
	,fundtype
	,InVaRLimit
	,inCompany


		
	from	
	(
		select basebie.*,fund.������ô���,fund.fundtype
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
						,iOTC.Notional,iOTC.DV01,iOTC.FixedRate,iOTC.PAY_FREQ,iOTC.�����ȼ�,InnerRating
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
								,sum(quantity) as quantity,sum(PresentValue) as PresentValue --���������ֲַ�����¼����
								from [Position_DB].[hld].[PurePosition] --������pureposition
								where [BALANCE_DATE] = @BalanceDate
								group by balance_date,account,dept,SECUCODE,SECUMARKET,SECUCATEGORY,underlying,UnderlyingMarket,ccy
							)as base1  
							left join 
							/*�˻���Ϣ*/
							(
								select subaccid,accid,deptid,invarlimit,inCompany
								from [Position_DB].[config].[AccountDeptMap1]  --�˻�ӳ���
							)as base2  
							on substring(base1.Account,patindex('%;%',base1.Account)+1,len(base1.Account))=base2.SubAccId
							where 
								PresentValue<>0
									 
								/* �Ǿ����˻���Ǿ����ʲ� */
								and (Base2.InCompany=1 
									or base2.subaccid='DKTR0401' 
									or base2.subaccid='ZYBH2701')--���ڹ�˾�ڲ��˻�,����͸���ʲ��������ӹ�˾
								and SubAccId<>'Dacheng' --�������͸��ľ����ʲ�,Ŀǰ���ݲ�׼
								and base2.AccId <> 'BX'--����
								and base2.subaccid <> 'YSPKJJY' --���ܲ��羳��������������Ϣ��ȫ

								/* ���м���*/
								and base2.AccId <> 'SWAP' --���滥��
								and base2.SubAccId <> 'ZJBJNH' --���滥��
								and base2.Subaccid <> 'JYSGH2' --���滥��
								and base2.Subaccid <> 'GPZYHG' --���ܹ�Ȩ��Ѻ�ع�

								/* �ѶԳ����*/
								and base2.Subaccid <> 'JYBJGR' --���ܽṹ�����ʷ����ѶԳ�
								and base2.SubAccId <> 'YSP-CWQQ' --���ܲ�������Ȩ�����ѶԳ�
								and base2.subaccid <> 'YSKJHH'--���ܲ����������ѶԳ�
								and base2.SubAccId <> 'TZGLB-SYQZC' --Ͷ�ʹ�������Ȩת���˻�----->?
								and base2.Subaccid <> 'F_A002' --����������˻��Գ���˻�																			
									
						)as base12
						left join 
						(
							/*����������Ϣ*/
							select code,FullCode 
							from position_db.xir.acc_balance_zq2 --��������
							where balance_date = @BalanceDate
							and department<>'�ⲿ' and notional<>0 
							group by code,fullcode
						)as base3
						on base12.Underlying=base3.code
					)as base

					left join 
					/*���ծȯ��Ϣ*/
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
								,(case [MKTNAME] when '�Ϻ�' then 'China_ShangHai' when '����' then 'China_ShenZhen' 
												when '���м�ծȯ' then 'China_InterBank' else NULL end) as Mkt_Type													
								FROM [Position_DB].[mkt].[WindIssuer] --ծȯ���з�����
							)as bond1      
							left join 
							(
								SELECT [COMP_NAME],[GRADE] 
								FROM [Position_DB].[mkt].[xir_CompanyRating]  --ծȯ���з���������
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
									select I_Code,B_Coupon,M_TYPE,B_MTR_Date from [Position_DB].[mkt].[xir_tbnd] --Ʊ������
								)as bond4
								left join
								(
									select I_Code,MK_DURATION,M_TYPE
									from Position_DB.xir.tbsi_bond  --ծȯ���� 
									where balance_date= @BalanceDate
								)as bond5 							
								on (bond4.I_Code=bond5.I_Code and bond4.M_TYPE=bond5.M_TYPE)
							)as bond45     
							left join
							(
								select curvename,SecuCode,SecuMarket
								from [Position_DB].[mkt].[BondCurveMapping] --ծȯ������������ӳ���
								where [balance_date] = @BalanceDate
							)as bond3     
							on (bond3.SecuCode=bond45.[I_Code] and bond3.SecuMarket=bond45.Mkt_Type)
						)as bond345     
						on (bond12.secucode=bond345.secucode and bond12.Mkt_Type=bond345.SecuMarket)
					)as bond
					on (base.Underlying = bond.SecuCode and base.UnderlyingMarket=bond.SecuMarket) --ȥ��secumarket�����ظ�

				)as baseb 
									
				
				left join
				/*���ʻ�����ծȯԶ����Ϣ*/
				( 
					select iOTC12.PositionCode,iOTC12.FullCode,iOTC12.SettleDay,iOTC34.CounterpartyName--���׶���ȫ��
					,iOTC12.Notional,iOTC12. DV01,iOTC12.FixedRate,iOTC12.PAY_FREQ ,iOTC12.Counterparter
					,(case when iOTC34.innerrating is null then 'Z-B5'  --���������հ׻�û�������ļٶ�ΪZ-B5��ÿ�μ�飡����
							when iOTC34.innerrating ='' then 'Z-B5'
							else iOTC34.innerrating end) as �����ȼ�
					,InnerRating
					from
					(
						select iOTC1.PositionCode,iOTC1.FullCode,iOTC1.SettleDay,iOTC1.Counterparter--���׶���ȫ��
						,iOTC1.Notional,iOTC1. DV01,iOTC1.FixedRate,iOTC2.PAY_FREQ
						from
						(
							select positioncode,fullcode,settleday
							,notional*10000 as Notional,dv01*10000 as DV01,FixedRate/100 as FixedRate
							,Counterparter
							from position_db.xir.acc_balance_zq2 -- ���ʻ�����ծȯԶ�ڵ��������롢�����ռ����׶�������
							where balance_date = @BalanceDate
							and department<>'�ⲿ' and notional<>0 
							and (tradetype='Զ��' or tradetype='���ʻ���') 
						)as iOTC1     
						left join
						(
							select I_Code,PAY_FREQ
							from Position_DB.mkt.xir_otcirswap --���ʻ�����ϢƵ��
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
							from [CreditRisk].[Reference].[CounterpartyMapping] 	--OTC���׶�������ת��
						)as iOTC3
						left join 
						(
							select CounterpartyName,InnerRating 
							from [CreditRisk].[Counterparty].[CounterpartyBasicInfo] --OTC���׶����ڲ�����
						)as iOTC4
						on iOTC3.InternalName=iOTC4.CounterpartyName
					)as iOTC34
					on iOTC12.Counterparter=iOTC34.OuterAlias collate Chinese_PRC_CI_AS_WS  --�����֣���( ��Ȼ���ظ�
				)as iOTC
				on baseb.secucode=iOTC.PositionCode
				--where 
				--/*ȥ���ڲ���Լ*/
				--(Counterparter is null or (	Counterparter not like '%����֤ȯ%' and Counterparter not like '%CSI%'))
			)as basebi
						
			left join
			/*��Ʊ��Ϣ*/
			(
				select localCode ��Ʊ����,issuerName ��Ʊ���й�˾ 
				from zx_audit.zx_mkt.v_getCurveIssuerInfo --��Ʊ���й�˾
			) as equity
			on basebi.underlying=[equity].[��Ʊ����]
		)as basebie

		left join
		(
			select underlying, underlyingmarket,������ô���,fundtype
			from
			( 
				select *
					,case when fund2.windcode is null then underlying+'.OF' else fund2.windcode end as ������ô��� 
				from
				(
					select underlying, underlyingmarket
					,(underlying+(case underlyingmarket when 'China_Shanghai'then '.SH' else '.SZ'end)) ԭʼ�������
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
					and v.dataSetId in (14,17,27) --14��17�����ڻ���27���������
					and v.balanceDate = @BalanceDate
					and v.tagvaluestr<>'��Ʊ�ͷּ��ӻ���' 
				)as fund2
				on fund1.ԭʼ�������=fund2.windCode
			) as fund12
			left join 
			(
				select v.windCode,v.tagValueStr fundType 
				from ZX_AUDIT.zx_mkt.v_tag_info v 
				where v.tagName = 'FUNDTYPE' 
				and v.dataSetId in (14,17,27) --14��17�����ڻ���27���������
				and v.balanceDate = @BalanceDate
				and v.tagvaluestr<>'��Ʊ�ͷּ��ӻ���'
			) as fund3
			on fund12.������ô���=fund3.windCode
			group by underlying, UnderlyingMarket,ԭʼ�������,������ô���,fund3.windCode,fundtype
		)as fund
		on (basebie.underlying=fund.underlying and basebie.underlyingmarket=fund.underlyingmarket)
	)as basebief		

	left join
		/*��Ȩ��Ϣ*/
	(
		SELECT substring(positionname,patindex('%_%',positionname)+1,7) as code,value as 'dollordelta1%'
		FROM [Audit_Bak].[RM_RUN].[Report_Global_Limit] --��Ȩdelta��Ϣ
		WHERE  balance_date =convert (varchar(10),@BalanceDate ,112)
		AND indicator = 'Equity Dollar Delta 1%'
		AND assettype = 'EQUITYOPTION' 
	)as option1
	on basebief.secucode=('1'+option1.code)
			
) as mRWA


)












GO
