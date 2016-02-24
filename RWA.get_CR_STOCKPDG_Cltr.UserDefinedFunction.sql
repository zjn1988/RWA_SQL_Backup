USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CR_STOCKPDG_Cltr]    Script Date: 2016/2/24 11:16:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-11-06,,>
-- Description:	<获得股权质押回购数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CR_STOCKPDG_Cltr]
( 
	@BalanceDate DATETIME 
)

RETURNS TABLE 
AS
RETURN 
(
	
select CONVERT(varchar(10), @BalanceDate , 111) as 结算日,合并盯市代码,抵押券代码,抵押券数量,抵押券市值
from 
(
	select distinct 合并盯市代码 合并盯市代码 from Position_DB.RWA.get_CR_STOCKPDG_Cont(@BalanceDate) 
)Cont1
left join 
(		
	select distinct AdjContractId
	,抵押券代码,sum(抵押券数量) as 抵押券数量,sum(抵押券市值)as 抵押券市值
	from 
	(select case when merge_contractid is null then contractid else merge_contractid end AdjContractId
		,抵押券代码,抵押券数量,抵押券市值
		from 
		(
			select 
				contractid
				,case cltr_mkt when 'XSHG' then cltr_secid +'.SH'
								when 'XSHE' then cltr_secid +'.SZ'END 
				as 抵押券代码
				,cltr_amount as 抵押券数量
				,cltr_value as 抵押券市值
			from Credit_DB.C_position.acc_balance_collateral
			where balance_date=@BalanceDate and assettype='STOCKPDG'and source='EQD'and cltr_assettype<>'CASH'
		)cltr
		left join [Credit_DB].[C_config].[View_StockPledge_Merge]  m1
		on cltr.contractid=m1.src_contractid
	) m2 
	group by AdjContractId,抵押券代码
)Dtl
on Cont1.合并盯市代码=Dtl.AdjContractId

	
)






GO
