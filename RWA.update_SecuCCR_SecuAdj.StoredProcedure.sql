USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_SecuAdj]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_SecuAdj]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;
	delete from Position_DB.[RWA].SecuCCR_SecuAdj Where [Balance_Date]=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
--------------------------------------------------------------------------------------------------
----2.SecuCCR_SecuInfo_Adj
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_SecuAdj);	
	insert into Position_DB.[RWA].SecuCCR_SecuAdj
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,证券代码
	,代码
	,市场
	,证券名称
	,证券类型
	,上市日期
	,日均成交量
	,收盘价
	,定性折算比例
	,最大折扣
	,最小折扣
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY 证券代码 ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	,CAST(证券代码 as varchar(255))
	,CAST(代码 as varchar(255))
	,CAST(市场 as varchar(255))
	,CAST(证券名称 as varchar(255))
	,CAST(证券类型 as varchar(255))
	,上市日期
	,CAST(日均成交量 as decimal(28,10))
	,CAST(收盘价 as decimal(28,10))
	,CAST(定性折算比例 as decimal(28,10))
	,CAST(最大折扣 as decimal(28,10))
	,CAST(最小折扣 as decimal(28,10))
	from position_db.rwa.get_secuccr_secuadj(@BalanceDate)

END





GO
