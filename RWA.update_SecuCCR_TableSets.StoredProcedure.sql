USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_TableSets]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_TableSets]
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
	delete from Position_DB.[RWA].SecuCCR_SecuAdj Where [Balance_Date]=@BalanceDate ;
	delete from Position_DB.[RWA].SecuCCR_Cltr Where [Balance_Date]=@BalanceDate ;
	delete from Position_DB.[RWA].SecuCCR_Netting Where balance_date=@BalanceDate ;
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

--------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------
----4.SecuCCR_Netting
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Netting);	
	insert into Position_DB.[RWA].SecuCCR_Netting
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,净额结算组合
	,业务类型
	,部门
	,客户
	,名义本金
	,总负债
	,总资产
	,维持担保比例
	,剩余期限
	,定性扣减
	,定量扣减
	,扣减上限
	,扣减下限
	,风险价值扣减
	,RWA等价折算率
	,RWA折算后资产
	,折算后维持担保比例
	,净风险敞口
	,主体内评等级
	,主体类型
	,PD
	,ULPD
	,LGD
	,期限调整
	,预期损失
	,非预期损失
	,净敞口风险权重
	,RWA
	,风险敞口占比
	,预期损失占比
	,非预期损失占比
	,RWA占比
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY 业务类型 ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	,CAST(净额结算组合 as varchar(255))
	,CAST(业务类型 as varchar(255))
	,CAST(部门 as varchar(255))
	,CAST(客户 as varchar(255))
	,CAST(名义本金 as decimal(28,10))
	,CAST(总负债 as decimal(28,10))
	,CAST(总资产 as decimal(28,10))
	,CAST(维持担保比例 as decimal(28,10))
	,CAST(剩余期限 as decimal(28,10))
	,CAST(定性扣减 as decimal(28,10))
	,CAST(定量扣减 as decimal(28,10))
	,CAST(扣减上限 as decimal(28,10))
	,CAST(扣减下限 as decimal(28,10))
	,CAST(风险价值扣减 as decimal(28,10))
	,CAST(RWA等价折算率 as decimal(28,10))
	,CAST(RWA折算后资产 as decimal(28,10))
	,CAST(折算后维持担保比例 as decimal(28,10))
	,CAST(净风险敞口 as decimal(28,10))
	,CAST(主体内评等级 as varchar(255))
	,CAST(主体类型 as  varchar(255))
	,CAST(PD as decimal(28,10))
	,CAST(ULPD as decimal(28,10))
	,CAST(LGD as decimal(28,10))
	,CAST(期限调整 as decimal(28,10))
	,CAST(预期损失 as decimal(28,10))
	,CAST(非预期损失 as decimal(28,10))
	,CAST(净敞口风险权重 as decimal(28,10))
	,CAST(RWA as decimal(28,10))
	,CAST(风险敞口占比 as decimal(28,10))
	,CAST(预期损失占比 as decimal(28,10))
	,CAST(非预期损失占比 as decimal(28,10))
	,CAST(RWA占比 as decimal(28,10))
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)
END




GO
