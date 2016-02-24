USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_Cltr]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_Cltr]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;

	delete from Position_DB.[RWA].SecuCCR_Cltr Where [Balance_Date]=@BalanceDate ;

	set @UpdateTime=(select GETDATE());
---------------------------------------------------------------------------------------------------
----3.SecuCCR_Cltr
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Cltr);	
	insert into Position_DB.[RWA].SecuCCR_Cltr
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,业务类型
	,净额结算识别码
	,证券代码
	,证券类型
	,证券市值
	,上市日期
	,流动性期限
	,定性扣减
	,扣减上限
	,扣减下限
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY 业务类型 ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	,CAST(业务类型 as varchar(255))
	,CAST(净额结算识别码 as varchar(255))
	,CAST(证券代码 as varchar(255))
	,CAST(证券类型 as varchar(255))
	,CAST(证券市值 as decimal(28,10))
	,上市日期
	,CAST(流动性期限 as decimal(28,10))
	,CAST(定性扣减 as decimal(28,10))
	,CAST(扣减上限 as decimal(28,10))
	,CAST(扣减下限 as decimal(28,10))
	from position_db.rwa.get_secuccr_Cltr(@BalanceDate)

END





GO
