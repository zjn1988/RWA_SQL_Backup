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

END





GO
