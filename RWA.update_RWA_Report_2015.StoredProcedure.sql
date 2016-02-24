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
		,��ϴ���
		,���
		,�ܹ�ģ
		,����ģ
		,SVaR
		,IRC
		,GeneralmRWA
		,SpecificmRWA
		,MktRWA
		,CreditRWA
		,StdRWA
		,TotalRWA
		,�۳������ʽ�ʹ�÷�����
		,RoRWA
		,VaR��Ч��
		,IRC��Ч��
		,CCR��Ч��
		,�ο�PnL
		,�ο�RoRWA
	)
	select 

	(ROW_NUMBER() OVER (ORDER BY ��ϴ��� ASC))+@MaxID AS ID
	,@BalanceDate--convert(varchar(10),@BalanceDate,111) as Balance_Date
		,��ϴ���--cast(��ϴ��� as varchar(4)) as ��ϴ���
		,���
		,�ܹ�ģ
		,����ģ
		,SVaR
		,IRC
		,SVaR*1.6*12.5 as  GeneralmRWA
		,IRC*12.5      as  SpecificmRWA
		,SVaR*1.6+IRC  as  MktRWA
		,CreditRWA
		,StdRWA
		,SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA as TotalRWA
		,�۳������ʽ�ʹ�÷�����
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			�۳������ʽ�ʹ�÷�����/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		 as RoRWA
		,VaR��Ч��
		,IRC��Ч��
		,CCR��Ч��
		,PnL �ο�PnL
		,(case when SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA<>0 then
			PnL/(SVaR*1.6*12.5+IRC*12.5+CreditRWA+StdRWA)*1 else 0 end)
		  as �ο�RoRWA

	from(
		select 
			abd.��ϴ���,abd.Accid ���,�ܹ�ģ,����ģ
			,0 as SVaR
			,0 as IRC
			,0 as CreditRWA
			,0 as StdRWA
			,PnL
			,0 as �۳������ʽ�ʹ�÷�����
			,VaR��Ч��
			,IRC��Ч��
			,0 as CCR��Ч��  --������

		from(select 
				ab.*,case when  d.��� is null then 0 else 1 end IRC��Ч��
			 from(select 
			         a.*	,case when b.��� is null then 0 else 1 end VaR��Ч�� 
				  from position_db.rwa.get_amount_account(@BalanceDate) as a 
				  left join(select distinct ���  
							from position_db.rwa.VarPositionDtl_v2 
							where  balance_date=@BalanceDate	
							)b 
				  on a.��ϴ���=b.���
				)ab 
				left join 
				(select distinct ��� from position_db.rwa.get_mRWA_IRCMtM(@BalanceDate))d on ab.��ϴ���=d.���)abd 
				left join	
				(select distinct ���,sum(PnL) PnL from(select left(���,2) ���,PnL 
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate))f  group by ���
					union all select ���,pnl 
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)where ���<>'����'
					union all select '��˾����',sum(pnl)
						from Position_DB.rwa.get_pnl(@StartDate,@BalanceDate)
				)c on abd.AccId=c.���
	)abdc
END






GO
