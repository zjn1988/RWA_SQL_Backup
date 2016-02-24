USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_SecuAdj]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_SecuAdj]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;
	delete from Position_DB.[RWA].SecuCCR_SecuAdj Where [Balance_Date]=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
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

END





GO
