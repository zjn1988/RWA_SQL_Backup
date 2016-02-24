USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_SVaRInfo]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_SVaRInfo]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	delete from Position_DB.[RWA].[SecuCCR_SVaRInfo] Where [Balance_Date]=@BalanceDate ;
--------------------------------------------------------------------------------------------------
----1.SecuCCR_SecuInfo
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].[SecuCCR_SVaRInfo]);
	
	insert into Position_DB.[RWA].[SecuCCR_SVaRInfo]
	(
	[ID]
	,Balance_Date
	,组合序号
	,识别码
	,SVaR
	,更新时间
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY 组合序号 ASC))+@MaxID AS ID
	,@BalanceDate Balance_Date
	,组合序号
	,识别码
	,0 SVaR  --手工添加
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
END





GO
