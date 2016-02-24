USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_SVaRInfo]    Script Date: 2016/2/24 13:10:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_SVaRInfo]
( 
	@BalanceDate DATE 

	)

RETURNS TABLE 
AS
RETURN 
(




select 

	@BalanceDate Balance_Date
	,������
	,ʶ����
	,0 as SVaR  --�ֹ����
	,@BalanceDate ����ʱ��  --�ֹ�����

from 
(
	SELECT ROW_NUMBER() OVER( ORDER BY ʶ���� ) AS ������,tmp1.* 
	FROM( 
		select distinct ҵ������+���������� as ʶ����
		from Position_DB.rwa.SecuCCR_Netting 
		where Balance_Date=@BalanceDate 
	)tmp1 
)tmp2

)


GO
