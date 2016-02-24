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
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_AGREPO]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(

select CONVERT(varchar(10), @balancedate , 111) as 结算日 
	,业务类型,部门,合约代码1 合约代码,客户代码1 客户代码
	,sum(名义本金)名义本金
	,sum(总负债) 总负债
	,抵押券代码
	,sum(抵押券数量) 抵押券数量
	,sum(抵押权市值) 抵押权市值
	,sum(现金资产) 现金资产
	,合约到期日1 合约到期日
from
(select distinct case when f.merge_contractid is null then e.合约代码 else f.merge_contractid end 合约代码1
	,e.*,f.*,g.客户代码2,g.合约到期日2
	,case when f.merge_contractid is null then e.客户代码 else g.客户代码2 end 客户代码1
	,case when f.merge_contractid is null then e.合约到期日 else g.合约到期日2 end 合约到期日1


from
	-- Add the SELECT statement with parameter references here
(	SELECT 
		a.assettype as 业务类型,
		a.dept as 部门,
		a.contractid as 合约代码,
		a.clientid as 客户代码,
		ISNULL(a.notional,0) AS 名义本金,		
		ISNULL(a.debt,0) AS  总负债,--总负债=负债金额+负债利息 --debt=debtAmount+debtInterest
		--a.[debtAmount],
		--a.[debtInterest],
		--a.[repayAmount],
		--a.[repayInterest],				
		case b.cltr_mkt
		when 'XSHG' then b.cltr_secid +'.SH'
		when 'XSHE' then b.cltr_secid +'.SZ'
		END as 抵押券代码,
		--b.cltr_secid ,
		--b.cltr_mkt,
		--b.cltr_assettype,
		--b.cltr_circtype,
		ISNULL(b.cltr_amount,0) AS  抵押券数量,
		ISNULL(b.cltr_value,0) AS  抵押权市值,
		0 as 现金资产,
		ISNULL(b.cltr_value,0)/ISNULL(a.debt,0) as 维持担保比例,
		CONVERT(varchar(10), a.maturity , 111)  as 合约到期日
		--,a.full_name as 客户全称	
		 
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
left join [Credit_DB].[C_config].[View_StockPledge_Merge] f on e.合约代码=f.src_contractid
left join 
	(	SELECT 
		a.contractid as 合约代码2,
		a.clientid as 客户代码2,
		CONVERT(varchar(10), a.maturity , 111)  as 合约到期日2
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
on f.merge_contractid=g.合约代码2
)h

group by 合约代码1, 客户代码1,业务类型,部门,抵押券代码,合约到期日1


)





GO
