USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_BondCurve]    Script Date: 2016/2/24 11:15:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<获得约定购回业务数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_BondCurve]
(	@StartDate DATETIME,
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from 
		(SELECT distinct(利率曲线) FROM [RWA].get_BondFwd (@BalanceDate)) as A
		left join
		(select curveNameCn,curveVertexName,price, CONVERT(varchar(10), dailyDate, 111) dailyDate
			from zx_audit.zx_mkt.v_getBondYield v
			where v.dailydate between @StartDate and @BalanceDate
		) as B
		ON A.利率曲线=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)

	--and c.balance_date=@BalanceDate
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC








GO
