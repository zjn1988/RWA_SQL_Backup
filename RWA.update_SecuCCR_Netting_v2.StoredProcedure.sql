USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_Netting_v2]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,ZHANGJIANNAN>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_Netting_v2]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;

	delete from Position_DB.[RWA].SecuCCR_Netting_2 Where balance_date=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
	------------------------------------------------------------------------------------
	--重新编号
	--select * into #TEMP from Position_DB.[RWA].SecuCCR_Netting_2;
	--DELETE  FROM Position_DB.[RWA].SecuCCR_Netting_2
	--insert into Position_DB.[RWA].SecuCCR_Netting_2(
	--	[ID],[UpdateTime],Balance_Date,净额结算组合,业务类型,部门,客户,名义本金,总负债
	--	,总资产,维持担保比例,剩余期限,定性扣减,定量扣减,扣减上限,扣减下限,风险价值扣减
	--	,RWA等价折算率,RWA折算后资产,折算后维持担保比例	,净风险敞口	,主体内评等级,主体类型
	--	,PD,ULPD,LGD,期限调整,预期损失,非预期损失,净敞口风险权重,RWA,风险敞口占比,预期损失占比
	--	,非预期损失占比,RWA占比
	--	)
	--SELECT 
	--	(ROW_NUMBER() OVER (ORDER BY [UpdateTime] ASC)) AS ID
	--	,[UpdateTime],Balance_Date,净额结算组合,业务类型,部门,客户,名义本金,总负债
	--	,总资产,维持担保比例,剩余期限,定性扣减,定量扣减,扣减上限,扣减下限,风险价值扣减
	--	,RWA等价折算率,RWA折算后资产,折算后维持担保比例	,净风险敞口	,主体内评等级,主体类型
	--	,PD,ULPD,LGD,期限调整,预期损失,非预期损失,净敞口风险权重,RWA,风险敞口占比,预期损失占比
	--	,非预期损失占比,RWA占比
	-- FROM #TEMP
	-- drop table #TEMP

--------------------------------------------------------------------------------------------------
----4.SecuCCR_Netting
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Netting_2);	
	
	select 
	(ROW_NUMBER() OVER (ORDER BY 业务类型 ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	--,CAST(净额结算组合 as varchar(255))
	--,CAST(业务类型 as varchar(255))
	--,CAST(部门 as varchar(255))
	--,CAST(客户 as varchar(255))
	--,CAST(名义本金 as decimal(28,10))
	--,CAST(总负债 as decimal(28,10))
	--,CAST(总资产 as decimal(28,10))
	--,CAST(维持担保比例 as decimal(28,10))
	--,CAST(剩余期限 as decimal(28,10))
	--,CAST(定性扣减 as decimal(28,10))
	--,CAST(定量扣减 as decimal(28,10))
	--,CAST(扣减上限 as decimal(28,10))
	--,CAST(扣减下限 as decimal(28,10))
	--,CAST(风险价值扣减 as decimal(28,10))
	--,CAST(RWA等价折算率 as decimal(28,10))
	--,CAST(RWA折算后资产 as decimal(28,10))
	--,CAST(折算后维持担保比例 as decimal(28,10))
	--,CAST(净风险敞口 as decimal(28,10))
	--,CAST(主体内评等级 as varchar(255))
	--,CAST(主体类型 as  varchar(255))
	--,CAST(PD as decimal(28,10))
	--,CAST(ULPD as decimal(28,10))
	--,CAST(LGD as decimal(28,10))
	--,CAST(期限调整 as decimal(28,10))
	--,CAST(预期损失 as decimal(28,10))
	--,CAST(非预期损失 as decimal(28,10))
	--,CAST(净敞口风险权重 as decimal(28,10))
	--,CAST(RWA as decimal(28,10))
	--,CAST(风险敞口占比 as decimal(28,10))
	--,CAST(预期损失占比 as decimal(28,10))
	--,CAST(非预期损失占比 as decimal(28,10))
	--,CAST(RWA占比 as decimal(28,10))
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
	into #TEMP2 
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)

	insert into Position_DB.[RWA].SecuCCR_Netting_2
	select
	ID
	,[UpdateTime]
	,[Balance_Date]
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
		,CAST(期限调整 as decimal(28,18))
		,CAST(预期损失 as decimal(28,10))
		,CAST(非预期损失 as decimal(28,10))
		,CAST(净敞口风险权重 as decimal(38,25))
		,CAST(RWA as decimal(28,10))
		,CAST(风险敞口占比 as decimal(28,10))
		,CAST(预期损失占比 as decimal(28,10))
		,CAST(非预期损失占比 as decimal(28,10))
		,CAST(RWA占比 as decimal(28,10))
	 from #TEMP2
	drop table #TEMP2
END





GO
