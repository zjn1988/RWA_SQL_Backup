USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_AGREPO]    Script Date: 2016/2/24 11:14:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<���Լ������ҵ������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_AGREPO]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(

select CONVERT(varchar(10), @balancedate , 111) as ������ 
	,ҵ������,����,��Լ����1 ��Լ����,�ͻ�����1 �ͻ�����
	,sum(���屾��)���屾��
	,sum(�ܸ�ծ) �ܸ�ծ
	,��Ѻȯ����
	,sum(��Ѻȯ����) ��Ѻȯ����
	,sum(��ѺȨ��ֵ) ��ѺȨ��ֵ
	,sum(�ֽ��ʲ�) �ֽ��ʲ�
	,��Լ������1 ��Լ������
from
(select distinct case when f.merge_contractid is null then e.��Լ���� else f.merge_contractid end ��Լ����1
	,e.*,f.*,g.�ͻ�����2,g.��Լ������2
	,case when f.merge_contractid is null then e.�ͻ����� else g.�ͻ�����2 end �ͻ�����1
	,case when f.merge_contractid is null then e.��Լ������ else g.��Լ������2 end ��Լ������1


from
	-- Add the SELECT statement with parameter references here
(	SELECT 
		a.assettype as ҵ������,
		a.dept as ����,
		a.contractid as ��Լ����,
		a.clientid as �ͻ�����,
		ISNULL(a.notional,0) AS ���屾��,		
		ISNULL(a.debt,0) AS  �ܸ�ծ,--�ܸ�ծ=��ծ���+��ծ��Ϣ --debt=debtAmount+debtInterest
		--a.[debtAmount],
		--a.[debtInterest],
		--a.[repayAmount],
		--a.[repayInterest],				
		case b.cltr_mkt
		when 'XSHG' then b.cltr_secid +'.SH'
		when 'XSHE' then b.cltr_secid +'.SZ'
		END as ��Ѻȯ����,
		--b.cltr_secid ,
		--b.cltr_mkt,
		--b.cltr_assettype,
		--b.cltr_circtype,
		ISNULL(b.cltr_amount,0) AS  ��Ѻȯ����,
		ISNULL(b.cltr_value,0) AS  ��ѺȨ��ֵ,
		0 as �ֽ��ʲ�,
		ISNULL(b.cltr_value,0)/ISNULL(a.debt,0) as ά�ֵ�������,
		CONVERT(varchar(10), a.maturity , 111)  as ��Լ������
		--,a.full_name as �ͻ�ȫ��	
		 
	from 
		
		( select    c.[source],c.[dept],c.[clientid],c.[contractid],c.[mkt],c.[assettype],c.[notional],c.[debt],c.[debtAmount],c.[debtInterest],
					c.[repayAmount],c.[repayInterest],c.[underlying_id],c.[underlying_mkt],c.[underlying_assetype],c.[underlying_amount],
					c.[maturity],c.[safe_ratio],c.[warning_ratio],c.[status],c.[balance_date],c.[import_time]
					--,d.[full_name],d.[id],d.[id_type],d.[client_type]
			from Credit_DB.C_position.acc_balance_contract as c
			--left join [Credit_DB].[C_client].[client_info] as d
			--on c.clientid=d.client_id
		) as a, 
		Credit_DB.C_position.acc_balance_collateral as b
		 
	WHERE 
			a.contractid=b.contractid
		and a.balance_date=@BalanceDate
		and b.balance_date=@BalanceDate
		and a.assettype='AGREPO'
)e
left join [Credit_DB].[C_config].[View_StockPledge_Merge] f on e.��Լ����=f.src_contractid
left join 
	(	SELECT 
		a.contractid as ��Լ����2,
		a.clientid as �ͻ�����2,
		CONVERT(varchar(10), a.maturity , 111)  as ��Լ������2
		from 
		
		( select    c.[source],c.[dept],c.[clientid],c.[contractid],c.[mkt],c.[assettype],c.[notional],c.[debt],c.[debtAmount],c.[debtInterest],
					c.[repayAmount],c.[repayInterest],c.[underlying_id],c.[underlying_mkt],c.[underlying_assetype],c.[underlying_amount],
					c.[maturity],c.[safe_ratio],c.[warning_ratio],c.[status],c.[balance_date],c.[import_time]
					--,d.[full_name],d.[id],d.[id_type],d.[client_type]
			from Credit_DB.C_position.acc_balance_contract as c
			--left join [Credit_DB].[C_client].[client_info] as d
			--on c.clientid=d.client_id
		) as a, 
		Credit_DB.C_position.acc_balance_collateral as b
		 
		WHERE 
				a.contractid=b.contractid
			and a.balance_date=@BalanceDate
			and b.balance_date=@BalanceDate
			and a.assettype='AGREPO'
	)g
on f.merge_contractid=g.��Լ����2
)h

group by ��Լ����1, �ͻ�����1,ҵ������,����,��Ѻȯ����,��Լ������1


)





GO
