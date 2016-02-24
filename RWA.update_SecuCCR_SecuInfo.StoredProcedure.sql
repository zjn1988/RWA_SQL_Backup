USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_SecuInfo]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_SecuInfo]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;
	delete from Position_DB.[RWA].SecuCCR_SecuInfo Where [Balance_Date]=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
--------------------------------------------------------------------------------------------------
----1.SecuCCR_SecuInfo
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_SecuInfo);
	
	insert into Position_DB.[RWA].SecuCCR_SecuInfo
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,证券代码
	,代码
	,市场
	,证券类型
	,证券名称
	,基金投资类型
	,上市日期
	,日均成交量
	,流通A股
	,收盘价
	,最近交易日
	,市净率
	,申万行业
	,最新债项评级
	,ROE1
	,ROE2
    ,[手工调整比例]
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY 证券代码 ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
    ,CAST(证券代码 as varchar(255))
	,CAST(代码 as varchar(255))
	,CAST(市场 as varchar(255))
	,CAST(证券类型 as varchar(255))
	,CAST(证券名称 as varchar(255))
	,CAST(基金投资类型 as varchar(255))
	,上市日期
	,CAST(日均成交量 as decimal(28,10))
	,CAST(流通A股 as decimal(28,10))
	,CAST(收盘价 as decimal(28,10))
	,最近交易日
	,CAST(市净率 as decimal(28,10))
	,CAST(申万行业 as varchar(255))
	,CAST(最新债项评级 as varchar(255))
	,CAST(ROE1 as decimal(28,10))
	,CAST(ROE2 as decimal(28,10))
	,CAST(手工调整比例 as decimal(28,10))
	from [RWA].[get_SecuCCR_SecuInfo] (@BalanceDate)

END





GO
