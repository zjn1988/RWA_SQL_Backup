USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RZRQ]    Script Date: 2016/2/24 11:18:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--融资融券debtinterest等于应付未付利息


-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_RZRQ]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
	CONVERT(varchar(10), @BalanceDate , 111) as 结算日,
	'RZRQ' AS 业务类型,部门,
	A.clientid,
	--A.客户全称,
	ISNULL(名义本金,0) AS 名义本金,
	ISNULL(现金负债,0) AS 现金负债,
		--融资业务: 现金负债=总负债=负债金额+负债利息=[debtAmount]+[debtInterest]
		--融券业务: 现金负债=利息负债=[debtInterest]
	ISNULL(证券负债,0) AS 证券负债,
		--融资业务: 证券负债=0
		--融券业务: 证券负债=负债金额=[debtAmount]
	ISNULL(证券资产,0) AS 证券资产,
		--证券资产=非CASH类资产
	ISNULL(现金资产,0) AS 现金资产,
		--证券资产=CASH类资产
	ISNULL(证券负债,0)+ISNULL(现金负债,0) AS 总负债,
	ISNULL(证券资产,0)+ISNULL(现金资产,0) AS 总资产,
	--case 现金负债	when NULL Then 0 else 现金负债	END 现金负债,
	--case 证券负债	when NULL Then 0 else 证券负债	END 证券负债,
	--case 证券资产 	when NULL Then 0 else 证券资产	END 证券资产,
	--case 现金资产	when NULL Then 0 else 现金资产	END 现金资产,
	--名义本金+现金负债 as 总负债,
	--证券资产+现金资产 as 总资产,
	(ISNULL(证券资产,0)+ISNULL(现金资产,0))/(ISNULL(证券负债,0)+ISNULL(现金负债,0)) as 维持担保比例
	FROM
	(
		SELECT C.clientid,C.部门,C.名义本金,C.现金负债,C.证券负债
		--,D.full_name AS 客户全称 
		FROM
		(		SELECT clientid,
					dept as 部门,					
					SUM(notional) 名义本金,									
					sum(CASE   assettype 
					when 'RZRQ_0' THEN debt
					when 'RZRQ_1' THEN debtInterest
					END)  as 现金负债,
					sum(CASE   assettype 
					when 'RZRQ_0' THEN  0			--融资
					when 'RZRQ_1' THEN debtAmount   --融券
					END)  as 证券负债
				FROM
				Credit_DB.C_position.acc_balance_contract
				WHERE balance_date=@BalanceDate
				AND LEFT(assettype,4)='RZRQ'
				GROUP BY clientid,dept
			) AS C
			--left join [Credit_DB].[C_client].[client_info] as D
			--on C.clientid=D.client_id
			
	) AS A
	LEFT JOIN
	(
			SELECT clientid,
				sum(CASE   cltr_assettype
				WHEN null THEN 0
				WHEN 'CASH' THEN 0 
				WHEN 'CASHFUND' THEN 0 
				ELSE cltr_value
				END) AS 证券资产,
				sum(CASE  when cltr_assettype in ( 'CASHFUND','CASH') THEN cltr_value
				END) AS 现金资产
			FROM 
			Credit_DB.C_position.acc_balance_collateral	
			WHERE balance_date=@BalanceDate
			AND assettype='RZRQ'
			GROUP BY clientid
	) AS B
	ON A.clientid=B.clientid

	
)




GO
