USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_VarPositionDtl]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_VarPositionDtl]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	delete from Position_DB.[RWA].VarPositionDtl Where [Balance_Date]=@BalanceDate ;
	
------------------
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].VarPositionDtl);
	insert into Position_DB.[RWA].VarPositionDtl
	(
	[ID]
	,[Balance_Date]
    ,[SVaRType]
	,[RiskFactor]
	,[到期天数]
	,[CurveName]
	,[公司总计]
	,[固定收益部]
	,[固收交易]
	,[固收财富管理]
	,[固收销售]
	,[夹层投资部]
	,[资金运营部]
	,[权益投资部]
	,[股衍业务线]
	,[另类量化]
	,[证金业务线]
	,[证金券池]
	,[证金股权及其他]
	,[其他]
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY SVaRType ASC))+@MaxID AS ID
	,@BalanceDate as [Balance_Date]
    ,CAST([SVaRType] as varchar(255))
	,CAST([RiskFactor] as varchar(255))
	,CAST([到期天数] as int)
	,CAST([CurveName] as varchar(255))
	,CAST([公司总计] as decimal(28,10))
	,CAST([固定收益部] as decimal(28,10))
	,CAST([固收交易] as decimal(28,10))
	,CAST([固收财富管理] as decimal(28,10))
	,CAST([固收销售] as decimal(28,10))
	,CAST([夹层投资部] as decimal(28,10))
	,CAST([资金运营部] as decimal(28,10))
	,CAST([权益投资部] as decimal(28,10))
	,CAST([股衍业务线] as decimal(28,10))
	,CAST([另类量化] as decimal(28,10))
	,CAST([证金业务线] as decimal(28,10))
	,CAST([证金券池] as decimal(28,10))
	,CAST([证金股权及其他] as decimal(28,10))
	,CAST([其他] as decimal(28,10))
	from [RWA].[get_mRWA_SVaR] (@BalanceDate)-- order by SVaRType,RiskFactor;

	--declare @total int 
 --   set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].[VarPositionDtlAdj]);
	--select @total=count(*) from Position_DB.[RWA].[VarPositionDtlAdj]);--获取表中总共需要增加多少行
	--	while(@MaxID<=@total)
	--	Begin 
			
	--		 --执行更新的语句 这个要看你的表数据有什么连续的特定条件没
	--	   set  @MaxID=@MaxID+1
	--	End
	 
END
--(isnull(max(isnull([ID],0)),0)+1,


GO
