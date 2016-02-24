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
	,[��������]
	,[CurveName]
	,[��˾�ܼ�]
	,[�̶����沿]
	,[���ս���]
	,[���ղƸ�����]
	,[��������]
	,[�в�Ͷ�ʲ�]
	,[�ʽ���Ӫ��]
	,[Ȩ��Ͷ�ʲ�]
	,[����ҵ����]
	,[��������]
	,[֤��ҵ����]
	,[֤��ȯ��]
	,[֤���Ȩ������]
	,[����]
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY SVaRType ASC))+@MaxID AS ID
	,@BalanceDate as [Balance_Date]
    ,CAST([SVaRType] as varchar(255))
	,CAST([RiskFactor] as varchar(255))
	,CAST([��������] as int)
	,CAST([CurveName] as varchar(255))
	,CAST([��˾�ܼ�] as decimal(28,10))
	,CAST([�̶����沿] as decimal(28,10))
	,CAST([���ս���] as decimal(28,10))
	,CAST([���ղƸ�����] as decimal(28,10))
	,CAST([��������] as decimal(28,10))
	,CAST([�в�Ͷ�ʲ�] as decimal(28,10))
	,CAST([�ʽ���Ӫ��] as decimal(28,10))
	,CAST([Ȩ��Ͷ�ʲ�] as decimal(28,10))
	,CAST([����ҵ����] as decimal(28,10))
	,CAST([��������] as decimal(28,10))
	,CAST([֤��ҵ����] as decimal(28,10))
	,CAST([֤��ȯ��] as decimal(28,10))
	,CAST([֤���Ȩ������] as decimal(28,10))
	,CAST([����] as decimal(28,10))
	from [RWA].[get_mRWA_SVaR] (@BalanceDate)-- order by SVaRType,RiskFactor;

	--declare @total int 
 --   set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].[VarPositionDtlAdj]);
	--select @total=count(*) from Position_DB.[RWA].[VarPositionDtlAdj]);--��ȡ�����ܹ���Ҫ���Ӷ�����
	--	while(@MaxID<=@total)
	--	Begin 
			
	--		 --ִ�и��µ���� ���Ҫ����ı�������ʲô�������ض�����û
	--	   set  @MaxID=@MaxID+1
	--	End
	 
END
--(isnull(max(isnull([ID],0)),0)+1,


GO
