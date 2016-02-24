USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CR_STOCKPDG_Cont]    Script Date: 2016/2/24 11:17:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-11-06,,>
-- Description:	<获得股权质押回购数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CR_STOCKPDG_Cont]
( 
	@BalanceDate DATETIME 
)

RETURNS TABLE 
AS
RETURN 
(
	

select 
	distinct 合并盯市代码,结算日,业务类型,部门,合并盯市客户,sum(名义本金)as 名义本金,sum(总负债)as 总负债
	,sum(总资产) as 总资产,sum(总资产)/sum(总负债) as 维持担保比例,合并盯市合约到期日
from
(
	select 结算日,业务类型,部门
	,case when 合并盯市代码 is null then 合约代码 else 合并盯市代码 end 合并盯市代码
	,case when 合并盯市代码 is null then 客户代码 else 合并盯市客户 end 合并盯市客户
	,名义本金,总负债,总资产
	,case when 合并盯市代码 is null then 合约到期日 else 合并盯市合约到期日 end 合并盯市合约到期日
	from
	(	
			select CONVERT(varchar(10), @BalanceDate , 111) as 结算日 
				,assettype as 业务类型
				,dept as 部门
				,contractid as 合约代码
				,clientid as 客户代码
				,notional as 名义本金
				,debt as 总负债
				,CONVERT(varchar(10), maturity , 111)  as 合约到期日
			from Credit_DB.C_position.acc_balance_contract 
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
	) as cont
	left join
	(
		select distinct contractid
			,sum(cltr_value) as 总资产
		from Credit_DB.C_position.acc_balance_collateral
		where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
		group by contractid
	) as cltr
	on cont.合约代码=cltr.contractid
	left join [Credit_DB].[C_config].[View_StockPledge_Merge]  m1
	on cont.合约代码=m1.src_contractid
	left join 
	(	
			select contractid as 合并盯市代码
				,clientid as 合并盯市客户
				,CONVERT(varchar(10), maturity , 111)  as 合并盯市合约到期日
			from Credit_DB.C_position.acc_balance_contract 
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'
	) as m2
	on m1.merge_contractid=m2.合并盯市代码
)summary
group by 合并盯市代码,结算日,业务类型,部门,合并盯市客户,合并盯市合约到期日


	
)







GO
