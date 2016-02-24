USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_VarPositionDtl_v2]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_VarPositionDtl_v2]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @mRWA_All_Num int;
	set @mRWA_All_Num=(select count(*) from Position_DB.[RWA].mRWA_All where BALANCE_DATE=@BalanceDate ); 
	if @mRWA_All_Num<=0
		begin
		 exec Position_DB.[RWA].get_RWA_All @BalanceDate
		end

	DECLARE @MaxID int;
	delete from Position_DB.[RWA].VarPositionDtl_v2 Where [Balance_Date]=@BalanceDate ;
	delete from Position_DB.[RWA].VarPositionDtlAdj_v2 Where [Balance_Date]=@BalanceDate ;
------------------
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].VarPositionDtl_v2);
	insert into Position_DB.[RWA].VarPositionDtl_v2
	(
	[ID]
	,[Balance_Date]
    ,[SVaRType]
	,[RiskFactor]
	,[到期天数]
	,[CurveName]
	,ValuationFactor
	,组合
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY SVaRType ASC))+@MaxID AS ID
	,@BalanceDate as [Balance_Date]
    ,CAST([SVaRType] as varchar(255))
	,CAST([RiskFactor] as varchar(255))
	,CAST([到期天数] as int)
	,CAST([CurveName] as varchar(255))
	,CAST([ValuationFactor] as decimal(28,10))
	,CAST([组合] as varchar(255))
	from [RWA].get_mRWA_SVaR2 (@BalanceDate)-- order by SVaRType,RiskFactor;

	------------------
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].VarPositionDtlAdj_v2);
	insert into Position_DB.[RWA].VarPositionDtlAdj_v2
	(
	[ID]
	,[Balance_Date]
    ,[SVaRType]
	,[RiskFactor]
	,[到期天数]
	,[CurveName]
	,ValuationFactor
	,组合
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY SVaRType ASC))+@MaxID AS ID
	,@BalanceDate as [Balance_Date]
    ,CAST([SVaRType] as varchar(255))
	,CAST([RiskFactor] as varchar(255))
	,CAST([到期天数] as int)
	,CAST([CurveName] as varchar(255))
	,CAST([ValuationFactor] as decimal(28,10))
	,CAST([组合] as varchar(255))
	from [RWA].get_mRWA_SVaR2 (@BalanceDate)-- order by SVaRType,RiskFactor;
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
