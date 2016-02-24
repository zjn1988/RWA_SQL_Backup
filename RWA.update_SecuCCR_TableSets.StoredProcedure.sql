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
	,֤ȯ����
	,����
	,�г�
	,֤ȯ����
	,֤ȯ����
	,����Ͷ������
	,��������
	,�վ��ɽ���
	,��ͨA��
	,���̼�
	,���������
	,�о���
	,������ҵ
	,����ծ������
	,ROE1
	,ROE2
    ,[�ֹ���������]
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY ֤ȯ���� ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
    ,CAST(֤ȯ���� as varchar(255))
	,CAST(���� as varchar(255))
	,CAST(�г� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,CAST(����Ͷ������ as varchar(255))
	,��������
	,CAST(�վ��ɽ��� as decimal(28,10))
	,CAST(��ͨA�� as decimal(28,10))
	,CAST(���̼� as decimal(28,10))
	,���������
	,CAST(�о��� as decimal(28,10))
	,CAST(������ҵ as varchar(255))
	,CAST(����ծ������ as varchar(255))
	,CAST(ROE1 as decimal(28,10))
	,CAST(ROE2 as decimal(28,10))
	,CAST(�ֹ��������� as decimal(28,10))
	from [RWA].[get_SecuCCR_SecuInfo] (@BalanceDate)

--------------------------------------------------------------------------------------------------
----2.SecuCCR_SecuInfo_Adj
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_SecuAdj);	
	insert into Position_DB.[RWA].SecuCCR_SecuAdj
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,֤ȯ����
	,����
	,�г�
	,֤ȯ����
	,֤ȯ����
	,��������
	,�վ��ɽ���
	,���̼�
	,�����������
	,����ۿ�
	,��С�ۿ�
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY ֤ȯ���� ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	,CAST(֤ȯ���� as varchar(255))
	,CAST(���� as varchar(255))
	,CAST(�г� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,��������
	,CAST(�վ��ɽ��� as decimal(28,10))
	,CAST(���̼� as decimal(28,10))
	,CAST(����������� as decimal(28,10))
	,CAST(����ۿ� as decimal(28,10))
	,CAST(��С�ۿ� as decimal(28,10))
	from position_db.rwa.get_secuccr_secuadj(@BalanceDate)

--------------------------------------------------------------------------------------------------
----3.SecuCCR_Cltr
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Cltr);	
	insert into Position_DB.[RWA].SecuCCR_Cltr
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
	,ҵ������
	,�������ʶ����
	,֤ȯ����
	,֤ȯ����
	,֤ȯ��ֵ
	,��������
	,����������
	,���Կۼ�
	,�ۼ�����
	,�ۼ�����
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY ҵ������ ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
	,CAST(ҵ������ as varchar(255))
	,CAST(�������ʶ���� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,CAST(֤ȯ���� as varchar(255))
	,CAST(֤ȯ��ֵ as decimal(28,10))
	,��������
	,CAST(���������� as decimal(28,10))
	,CAST(���Կۼ� as decimal(28,10))
	,CAST(�ۼ����� as decimal(28,10))
	,CAST(�ۼ����� as decimal(28,10))
	from position_db.rwa.get_secuccr_Cltr(@BalanceDate)
--------------------------------------------------------------------------------------------------
----4.SecuCCR_Netting
	set @MaxID=(select isnull(max(ID),0) from Position_DB.[RWA].SecuCCR_Netting);	
	insert into Position_DB.[RWA].SecuCCR_Netting
	(
	[ID]
	,[UpdateTime]
	,Balance_Date
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
	)
	select 
	(ROW_NUMBER() OVER (ORDER BY ҵ������ ASC))+@MaxID AS ID
	,@UpdateTime as [UpdateTime]
	,@BalanceDate as [Balance_Date]
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
	,CAST(���޵��� as decimal(28,10))
	,CAST(Ԥ����ʧ as decimal(28,10))
	,CAST(��Ԥ����ʧ as decimal(28,10))
	,CAST(�����ڷ���Ȩ�� as decimal(28,10))
	,CAST(RWA as decimal(28,10))
	,CAST(���ճ���ռ�� as decimal(28,10))
	,CAST(Ԥ����ʧռ�� as decimal(28,10))
	,CAST(��Ԥ����ʧռ�� as decimal(28,10))
	,CAST(RWAռ�� as decimal(28,10))
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)
END




GO
