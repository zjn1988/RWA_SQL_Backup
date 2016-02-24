USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_STOCKPDG(old)]    Script Date: 2016/2/24 13:10:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_STOCKPDG(old)]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		CONVERT(varchar(10), @BalanceDate , 111) as 结算日 ,
		--a.balance_date as 结算日,
		a.[source] as 系统来源,
		a.assettype as 业务类型,
		a.dept as 部门,
		a.contractid as 合约代码,
		a.clientid as 客户代码,
		a.notional as 名义本金,		
		a.debt as 总负债,
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
		b.cltr_amount as 抵押券数量,
		b.cltr_value as 抵押权市值,
		isnull(a.现金资产,0) 现金资产,
		(isnull(b.cltr_value,0)+isnull(a.现金资产,0))/a.debt as 维持担保比,
		CONVERT(varchar(10), a.maturity , 111)  as 合约到期日
		--,a.full_name as 客户全称	
		 
	from 
		
		( select    c.[source],c.[dept],c.[clientid],c.[contractid],c.[mkt],c.[assettype],c.[notional],c.[debt],c.[debtAmount],c.[debtInterest],
					c.[repayAmount],c.[repayInterest],c.[underlying_id],c.[underlying_mkt],c.[underlying_assetype],c.[underlying_amount],
					c.[maturity],c.[safe_ratio],c.[warning_ratio],c.[status],c.[balance_date],c.[import_time]
					--,d.[full_name],d.[id],d.[id_type],d.[client_type]
					,e.现金资产
			FROM
			(select * from Credit_DB.C_position.acc_balance_contract where balance_date=@BalanceDate
			      and assettype='STOCKPDG') as c
			left join
			(SELECT 
					contractid,
					SUM(cltr_value) as 现金资产
					--cltr_value as 现金资产
  			    FROM
				Credit_DB.C_position.acc_balance_collateral
				WHERE  balance_date=@BalanceDate
				AND assettype='STOCKPDG'
				AND cltr_assettype='CASH'
				GROUP BY contractid
			) as e
			on c.contractid=e.contractid
			--left join [Credit_DB].[C_client].[client_info] as d
			--on c.[clientid]=d.client_id
		) as a
		left join
		(Select * from 
		Credit_DB.C_position.acc_balance_collateral
		where balance_date=@BalanceDate and assettype='STOCKPDG' and cltr_assettype<>'CASH') as b
		on	 
			a.contractid=b.contractid
	
)


--SELECT 
	--				contractid,
					--SUM(cltr_value) as 现金资产
--					cltr_value as 现金资产
--				FROM--
	--			Credit_DB.C_position.acc_balance_collateral
		--		WHERE  balance_date=@BalanceDate
			---	AND assettype='STOCKPDG'
			--	AND cltr_assettype='CASH'
				--GROUP BY contractid
GO
