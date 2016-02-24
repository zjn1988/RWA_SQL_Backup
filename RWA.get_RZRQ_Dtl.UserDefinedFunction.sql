USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RZRQ_Dtl]    Script Date: 2016/2/24 11:19:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_RZRQ_Dtl]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	Select CONVERT(varchar(10), @BalanceDate , 111) as 结算日,
	'RZRQ' AS 业务类型, 
	A.clientid,
	证券代码,
	ISNULL(证券数量,0) AS 证券数量,
	ISNULL(证券市值,0) AS 证券市值,
	资产类型
	from
	(select clientid
	FROM Position_DB.RWA.get_RZRQ(@BalanceDate)) as A,
	(select
		clientid,
		CASE cltr_mkt
		WHEN 'XSHE' THEN cltr_secid+'.SZ'
		WHEN 'XSHG' THEN cltr_secid+'.SH'
		END as 证券代码,
		sum([cltr_amount]) as 证券数量,
		sum([cltr_value]) as 证券市值,
		cltr_assettype as 资产类型
	 from
	Credit_DB.C_position.acc_balance_collateral	
	where balance_date=@BalanceDate
	and assettype='RZRQ'
	and (cltr_assettype is not null and cltr_assettype <>'CASH' and cltr_assettype <>'CASHFUND' and cltr_assettype <>'WARRANT')
	group by clientid,cltr_mkt,cltr_secid,cltr_assettype
	)	
	as B
	where A.clientid=B.clientid
		
)





GO
