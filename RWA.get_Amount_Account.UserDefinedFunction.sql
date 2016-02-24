USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_Amount_Account]    Script Date: 2016/2/24 11:14:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









/* =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-16,,>
-- Description:	<用于计算RWA口径下的投资规模>

前置任务:已手工执行过当日的mRWA_all存储过程

-- ===========================================*/
CREATE FUNCTION [RWA].[get_Amount_Account]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select '0000' 组合代码,'公司整体' AccId,sum(case when 投资规模>0 then 投资规模 else -投资规模 end) 总规模,sum(投资规模) 净规模,Balance_date
from(	select distinct 证券识别码,secucategory,secucode,sum(投资规模) 投资规模,Balance_date
	from position_db.rwa.get_Amount_Secu(@balancedate) 
	group by 证券识别码,secucategory,secucode,Balance_date
)b group by Balance_date

union all

select distinct 组合代码,Accid,sum(case when 投资规模>0 then 投资规模 else -投资规模 end) 总规模,sum(投资规模) 净规模,Balance_date
from(	select distinct 证券识别码,left(组合代码,2)+'00' 组合代码,left(Accid,2) Accid,secucategory,secucode,sum(投资规模) 投资规模,Balance_date
	from position_db.rwa.get_Amount_Secu(@balancedate)
	group by 证券识别码,组合代码,accid,secucategory,secucode,Balance_date
)a group by 组合代码,Accid,Balance_date

union all

select distinct 组合代码,AccId,sum(case when 投资规模>0 then 投资规模 else -投资规模 end) 总规模,sum(投资规模) 净规模,Balance_date
from position_db.rwa.get_Amount_Secu(@balancedate)
where 组合代码<>'0700'
group by 组合代码,accid,Balance_date



)






GO
