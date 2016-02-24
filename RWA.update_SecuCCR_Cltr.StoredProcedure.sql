USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_Cltr]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_Cltr]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;

	delete from Position_DB.[RWA].SecuCCR_Cltr Where [Balance_Date]=@BalanceDate ;

	set @UpdateTime=(select GETDATE());
---------------------------------------------------------------------------------------------------
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

END





GO
