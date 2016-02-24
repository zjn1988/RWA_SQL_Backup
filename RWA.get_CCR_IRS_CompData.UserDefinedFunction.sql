USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRS_CompData]    Script Date: 2016/2/24 11:16:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-19,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS_CompData]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select Balance_date,账户范围,净额结算#,组合名称,SecuCode,Settleday,固定利率,年付次数,Notional,曲线代码	
,PresentValue_CNY	
from	
(	
	select * from (SELECT ROW_NUMBER() OVER( ORDER BY 组合名称 ) AS 净额结算#,tmp1.* 
	FROM( select distinct CounterpartyName as 组合名称 from Position_DB.rwa.get_CCR_IRS(@balancedate)) as tmp1 )tmp2
) as Acc1	
left join	
(	
	select  Balance_date,'公司' as 账户范围,CounterpartyName as 识别码,SecuCode,Settleday,固定利率,年付次数,Notional,曲线代码
	,标的代码,PresentValue_CNY
	from Position_DB.rwa.get_CCR_IRS(@balancedate)
) as Acc2	
on 组合名称=识别码	

)


GO
