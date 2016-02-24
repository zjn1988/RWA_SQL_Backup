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
	--���±��
	--select * into #TEMP from Position_DB.[RWA].SecuCCR_Netting_2;
	--DELETE  FROM Position_DB.[RWA].SecuCCR_Netting_2
	--insert into Position_DB.[RWA].SecuCCR_Netting_2(
	--	[ID],[UpdateTime],Balance_Date,����������,ҵ������,����,�ͻ�,���屾��,�ܸ�ծ
	--	,���ʲ�,ά�ֵ�������,ʣ������,���Կۼ�,�����ۼ�,�ۼ�����,�ۼ�����,���ռ�ֵ�ۼ�
	--	,RWA�ȼ�������,RWA������ʲ�,�����ά�ֵ�������	,�����ճ���	,���������ȼ�,��������
	--	,PD,ULPD,LGD,���޵���,Ԥ����ʧ,��Ԥ����ʧ,�����ڷ���Ȩ��,RWA,���ճ���ռ��,Ԥ����ʧռ��
	--	,��Ԥ����ʧռ��,RWAռ��
	--	)
	--SELECT 
	--	(ROW_NUMBER() OVER (ORDER BY [UpdateTime] ASC)) AS ID
	--	,[UpdateTime],Balance_Date,����������,ҵ������,����,�ͻ�,���屾��,�ܸ�ծ
	--	,���ʲ�,ά�ֵ�������,ʣ������,���Կۼ�,�����ۼ�,�ۼ�����,�ۼ�����,���ռ�ֵ�ۼ�
	--	,RWA�ȼ�������,RWA������ʲ�,�����ά�ֵ�������	,�����ճ���	,���������ȼ�,��������
	--	,PD,ULPD,LGD,���޵���,Ԥ����ʧ,��Ԥ����ʧ,�����ڷ���Ȩ��,RWA,���ճ���ռ��,Ԥ����ʧռ��
	--	,��Ԥ����ʧռ��,RWAռ��
	-- FROM #TEMP
	-- drop table #TEMP

--------------------------------------------------------------------------------------------------
----4.SecuCCR_Netting
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Netting_2);	
	
	select 
	(ROW_NUMBER() OVER (ORDER BY ҵ������ ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	--,CAST(���������� as varchar(255))
	--,CAST(ҵ������ as varchar(255))
	--,CAST(���� as varchar(255))
	--,CAST(�ͻ� as varchar(255))
	--,CAST(���屾�� as decimal(28,10))
	--,CAST(�ܸ�ծ as decimal(28,10))
	--,CAST(���ʲ� as decimal(28,10))
	--,CAST(ά�ֵ������� as decimal(28,10))
	--,CAST(ʣ������ as decimal(28,10))
	--,CAST(���Կۼ� as decimal(28,10))
	--,CAST(�����ۼ� as decimal(28,10))
	--,CAST(�ۼ����� as decimal(28,10))
	--,CAST(�ۼ����� as decimal(28,10))
	--,CAST(���ռ�ֵ�ۼ� as decimal(28,10))
	--,CAST(RWA�ȼ������� as decimal(28,10))
	--,CAST(RWA������ʲ� as decimal(28,10))
	--,CAST(�����ά�ֵ������� as decimal(28,10))
	--,CAST(�����ճ��� as decimal(28,10))
	--,CAST(���������ȼ� as varchar(255))
	--,CAST(�������� as  varchar(255))
	--,CAST(PD as decimal(28,10))
	--,CAST(ULPD as decimal(28,10))
	--,CAST(LGD as decimal(28,10))
	--,CAST(���޵��� as decimal(28,10))
	--,CAST(Ԥ����ʧ as decimal(28,10))
	--,CAST(��Ԥ����ʧ as decimal(28,10))
	--,CAST(�����ڷ���Ȩ�� as decimal(28,10))
	--,CAST(RWA as decimal(28,10))
	--,CAST(���ճ���ռ�� as decimal(28,10))
	--,CAST(Ԥ����ʧռ�� as decimal(28,10))
	--,CAST(��Ԥ����ʧռ�� as decimal(28,10))
	--,CAST(RWAռ�� as decimal(28,10))
	,����������
	,ҵ������
	,����
	,�ͻ�
	,���屾��
	,�ܸ�ծ
	,���ʲ�
	,ά�ֵ�������
	,ʣ������
	,���Կۼ�
	,�����ۼ�
	,�ۼ�����
	,�ۼ�����
	,���ռ�ֵ�ۼ�
	,RWA�ȼ�������
	,RWA������ʲ�
	,�����ά�ֵ�������
	,�����ճ���
	,���������ȼ�
	,��������
	,PD
	,ULPD
	,LGD
	,���޵���
	,Ԥ����ʧ
	,��Ԥ����ʧ
	,�����ڷ���Ȩ��
	,RWA
	,���ճ���ռ��
	,Ԥ����ʧռ��
	,��Ԥ����ʧռ��
	,RWAռ��
	into #TEMP2 
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)

	insert into Position_DB.[RWA].SecuCCR_Netting_2
	select
	ID
	,[UpdateTime]
	,[Balance_Date]
		,CAST(���������� as varchar(255))
		,CAST(ҵ������ as varchar(255))
		,CAST(���� as varchar(255))
		,CAST(�ͻ� as varchar(255))
		,CAST(���屾�� as decimal(28,10))
		,CAST(�ܸ�ծ as decimal(28,10))
		,CAST(���ʲ� as decimal(28,10))
		,CAST(ά�ֵ������� as decimal(28,10))
		,CAST(ʣ������ as decimal(28,10))
		,CAST(���Կۼ� as decimal(28,10))
		,CAST(�����ۼ� as decimal(28,10))
		,CAST(�ۼ����� as decimal(28,10))
		,CAST(�ۼ����� as decimal(28,10))
		,CAST(���ռ�ֵ�ۼ� as decimal(28,10))
		,CAST(RWA�ȼ������� as decimal(28,10))
		,CAST(RWA������ʲ� as decimal(28,10))
		,CAST(�����ά�ֵ������� as decimal(28,10))
		,CAST(�����ճ��� as decimal(28,10))
		,CAST(���������ȼ� as varchar(255))
		,CAST(�������� as  varchar(255))
		,CAST(PD as decimal(28,10))
		,CAST(ULPD as decimal(28,10))
		,CAST(LGD as decimal(28,10))
		,CAST(���޵��� as decimal(28,18))
		,CAST(Ԥ����ʧ as decimal(28,10))
		,CAST(��Ԥ����ʧ as decimal(28,10))
		,CAST(�����ڷ���Ȩ�� as decimal(38,25))
		,CAST(RWA as decimal(28,10))
		,CAST(���ճ���ռ�� as decimal(28,10))
		,CAST(Ԥ����ʧռ�� as decimal(28,10))
		,CAST(��Ԥ����ʧռ�� as decimal(28,10))
		,CAST(RWAռ�� as decimal(28,10))
	 from #TEMP2
	drop table #TEMP2
END





GO
