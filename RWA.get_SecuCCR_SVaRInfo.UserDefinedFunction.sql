USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_SVaRInfo]    Script Date: 2016/2/24 13:10:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_SVaRInfo]
( 
	@BalanceDate DATE 

	)

RETURNS TABLE 
AS
RETURN 
(




select 

	@BalanceDate Balance_Date
	,组合序号
	,识别码
	,0 as SVaR  --手工添加
	,@BalanceDate 更新时间  --手工调整

from 
(
	SELECT ROW_NUMBER() OVER( ORDER BY 识别码 ) AS 组合序号,tmp1.* 
	FROM( 
		select distinct 业务类型+净额结算组合 as 识别码
		from Position_DB.rwa.SecuCCR_Netting 
		where Balance_Date=@BalanceDate 
	)tmp1 
)tmp2

)


GO
