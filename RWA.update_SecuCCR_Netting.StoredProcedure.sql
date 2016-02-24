USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_Netting]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,ZHANGJIANNAN>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_Netting]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;

	delete from Position_DB.[RWA].SecuCCR_Netting Where balance_date=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
	------------------------------------------------------------------------------------
	--重新编号
	select * into #TEMP from Position_DB.[RWA].SecuCCR_Netting;
	DELETE  FROM Position_DB.[RWA].SecuCCR_Netting
	insert into Position_DB.[RWA].SecuCCR_Netting(
		[ID],[UpdateTime],Balance_Date,净额结算组合,业务类型,部门,客户,名义本金,总负债
		,总资产,维持担保比例,剩余期限,定性扣减,定量扣减,扣减上限,扣减下限,风险价值扣减
		,RWA等价折算率,RWA折算后资产,折算后维持担保比例	,净风险敞口	,主体内评等级,主体类型
		,PD,ULPD,LGD,期限调整,预期损失,非预期损失,净敞口风险权重,RWA,风险敞口占比,预期损失占比
		,非预期损失占比,RWA占比
		)
	SELECT 
		(ROW_NUMBER() OVER (ORDER BY [UpdateTime] ASC)) AS ID
		,[UpdateTime],Balance_Date,净额结算组合,业务类型,部门,客户,名义本金,总负债
		,总资产,维持担保比例,剩余期限,定性扣减,定量扣减,扣减上限,扣减下限,风险价值扣减
		,RWA等价折算率,RWA折算后资产,折算后维持担保比例	,净风险敞口	,主体内评等级,主体类型
		,PD,ULPD,LGD,期限调整,预期损失,非预期损失,净敞口风险权重,RWA,风险敞口占比,预期损失占比
		,非预期损失占比,RWA占比
	 FROM #TEMP
	 drop table #TEMP

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
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)
	--from(	
	--	select *
	--		,非预期损失*12.5 RWA
	--		,case when 总负债=0 then 0 else 净风险敞口/总负债 end 风险敞口占比
	--		,case when 总负债=0 then 0 else 预期损失/总负债 end 预期损失占比
	--		,case when 总负债=0 then 0 else 非预期损失/总负债 end 非预期损失占比
	--		,case when 总负债=0 then 0 else 非预期损失/总负债*12.5 end RWA占比
	
	--	from(	select *
	--			,净风险敞口*PD*LGD*期限调整 预期损失
	--			,净风险敞口*ULPD*LGD*期限调整 非预期损失
	--			,ULPD*LGD*期限调整*12.5 净敞口风险权重

	--		from(	select e.*
	--				,v.PD
	--				,case 主体类型 when '个人' then IndivULPD when '银行' then BankULPD else CompULPD end ULPD
	--				,0.6 LGD
	--				,剩余期限/365*mAdjust1+mAdjust2 期限调整

	--			from(	select *
	--					,case when 总资产=0 then 0 else 风险价值扣减/总资产*1 end RWA等价折算率
	--					,总资产-风险价值扣减 RWA折算后资产
	--					,case when 总负债=0 then 0 else (总资产-风险价值扣减)/总负债*1 end  折算后维持担保比例
	--					,case when 总资产<=0 then 0 else case when 总资产-风险价值扣减>总负债 then 0 else 总负债-总资产+风险价值扣减 end end 净风险敞口
	--					,'Z-B5' as 主体内评等级
	--					,'通用' as 主体类型

	--				from(
	--					select *
	--						,case when 总资产<0 then 0 else case when 定性扣减+定量扣减>扣减上限 then 扣减上限
	--															when 定性扣减+定量扣减<扣减下限 then 扣减下限
	--															else 定性扣减+定量扣减 end end 风险价值扣减
	
	--					from(	select balance_date,净额结算组合,业务类型,部门,客户
	--							,名义本金,总负债,总资产,维持担保比例,剩余期限
	--							,isnull(定性扣减,0) 定性扣减
	--							,isnull(SVaR,0) as 定量扣减
	--							,isnull(扣减上限,总资产) 扣减上限,isnull(扣减下限,0) 扣减下限
	
	--						from (
	--							select 结算日 as balance_date, 客户编号 净额结算组合,业务类型,账户类型 部门,客户编号 客户
	--								,sum(名义本金) 名义本金,sum(总负债) 总负债,sum(总资产) 总资产,case when sum(总负债)<=0 then 0 else sum(总资产)/sum(总负债)*1 end 维持担保比例,0.5 剩余期限 
	--							from position_db.rwa.get_TRS_ContractInfo(@balancedate) 
	--							group by 结算日,客户编号,业务类型,账户类型
	--						union all 
	--							select 结算日, clientid,业务类型,部门,clientid,sum(名义本金),sum(总负债),sum(总资产),case when sum(总负债)<=0 then 0 else sum(总资产)/sum(总负债)*1 end,0.5
	--							from position_db.rwa.get_RZRQ(@balancedate)  
	--							group by 结算日, clientid,业务类型,部门,clientid
	--						union all 
	--							select 结算日,合并盯市代码,业务类型,部门,合并盯市客户,sum(名义本金),sum(总负债),sum(总资产)
	--								,case when sum(总负债)<=0 then 0 else sum(总资产)/sum(总负债)*1 end, datediff(day,@balancedate,合并盯市合约到期日)
	--							from position_db.rwa.get_CR_STOCKPDG_Cont(@balancedate)  
	--							group by 结算日,合并盯市代码,业务类型,部门,合并盯市客户,合并盯市合约到期日
	--						union all 
	--							select 结算日,合约代码,业务类型,部门,客户代码,sum(名义本金),sum(总负债),sum(抵押权市值+现金资产)
	--										,case when sum(总负债)<=0 then 0 else sum(抵押权市值+现金资产)/sum(总负债)*1 end, datediff(day,@balancedate,合约到期日)
	--							from position_db.rwa.get_AGREPO(@balancedate)  
	--							group by 结算日,合约代码,业务类型,部门,客户代码,合约到期日
	--						)a 
	--						left join 
	--						(
	--							select 净额结算识别码,sum(流动性期限*证券市值)/sum(证券市值)*1 组合流动性期限
	--								,sum(定性扣减) 定性扣减,sum(扣减上限) 扣减上限,sum(扣减下限) 扣减下限
	--							from Position_DB.rwa.SecuCCR_Cltr 
	--							where Balance_Date=@balancedate 
	--							group by 净额结算识别码
	--						)b
	--							on a.业务类型+a.净额结算组合=b.净额结算识别码
	--						left join
	--						(
	--							select SVaR,识别码 
	--							from Position_DB.rwa.SecuCCR_SVaRInfo 
	--							where Balance_Date=@BalanceDate
	--						)h
	--							on a.业务类型+a.净额结算组合=h.识别码
	--					)c 
	--				)d 
	--			)e left join position_db.rwa.parameter_ULPDMatrix() v
	--			on e.主体内评等级=v.InnerRating
	--		)f
	--	)g
	--) as zz

END





GO
