USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_RWA_Report_2015]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_RWA_Report_2015]
	-- Add the parameters for the stored procedure here
	@StartDate date,
	@BalanceDate date 
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET ANSI_WARNINGS  OFF 
	SET NOCOUNT ON;
	DECLARE @MaxID int;
--	declare @UpdateTime datetime;
	delete from Position_DB.[RWA].RWA_Report Where [Balance_Date]=@BalanceDate ;
	
------------------
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].RWA_Report);
--	set @UpdateTime=(select GETDATE());
	insert into Position_DB.[RWA].RWA_Report
	(
		[ID]
		,Balance_Date
		,组合代码
		,组合
		,总规模
		,净规模
		,SVaR
		,IRC
		,GeneralmRWA
		,SpecificmRWA
		,MktRWA
		,CreditRWA
		,StdRWA
		,TotalRWA
		,扣除其他资金使用费收益
		,RoRWA
		,VaR有效性
		,IRC有效性
		,CCR有效性
		,参考PnL
		,参考RoRWA
	)
	select 

	(ROW_NUMBER() OVER (ORDER BY 组合代码 ASC))+@MaxID AS ID
	,@BalanceDate--convert(varchar(10),@BalanceDate,111) as Balance_Date
		,组合代码--cast(组合代码 as varchar(4)) as 组合代码
		,组合
		,总规模
		,净规模
		,SVaR
		,IRC
		,SVaR*1.6*12.5 as  GeneralmRWA
		,IRC*12.5      as  SpecificmRWA
		,SVaR*1.6+IRC  as  MktRWA
		,CreditRWA
		,StdRWA
		,SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA as TotalRWA
		,扣除其他资金使用费收益
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			扣除其他资金使用费收益/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		 as RoRWA
		,VaR有效性
		,IRC有效性
		,CCR有效性
		,PnL 参考PnL
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			PnL/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		  as 参考RoRWA

	from(
		select 
			abd.组合代码,abd.Accid 组合,总规模,净规模
			,0 as SVaR
			,0 as IRC
			,0 as CreditRWA
			,0 as StdRWA
			,PnL
			,0 as 扣除其他资金使用费收益
			,VaR有效性
			,IRC有效性
			,0 as CCR有效性  --待完善

		from(select 
				ab.*,case when  d.组合 is null then 0 else 1 end IRC有效性
			 from(select 
			         a.*	,case when b.组合 is null then 0 else 1 end VaR有效性 
				  from position_db.rwa.get_amount_account(@BalanceDate) as a 
				  left join(select distinct 组合  
							from position_db.rwa.VarPositionDtl_v2 
							where  balance_date=@BalanceDate	
							)b 
				  on a.组合代码=b.组合
				)ab 
				left join 
				(select distinct 组合 from position_db.rwa.get_mRWA_IRCMtM(@BalanceDate))d on ab.组合代码=d.组合)abd 
				left join	
				(select distinct 组合,sum(PnL) PnL from(select left(组合,2) 组合,PnL 
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate))f  group by 组合
					union all select 组合,pnl 
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)where 组合<>'大宗'
					union all select '公司整体',sum(pnl)
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)
				)c on abd.AccId=c.组合
	)abdc
END






GO
