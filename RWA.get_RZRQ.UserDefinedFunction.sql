USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_RZRQ]    Script Date: 2016/2/24 11:18:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--������ȯdebtinterest����Ӧ��δ����Ϣ


-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<���Լ������ҵ������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_RZRQ]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
	CONVERT(varchar(10), @BalanceDate , 111) as ������,
	'RZRQ' AS ҵ������,����,
	A.clientid,
	--A.�ͻ�ȫ��,
	ISNULL(���屾��,0) AS ���屾��,
	ISNULL(�ֽ�ծ,0) AS �ֽ�ծ,
		--����ҵ��: �ֽ�ծ=�ܸ�ծ=��ծ���+��ծ��Ϣ=[debtAmount]+[debtInterest]
		--��ȯҵ��: �ֽ�ծ=��Ϣ��ծ=[debtInterest]
	ISNULL(֤ȯ��ծ,0) AS ֤ȯ��ծ,
		--����ҵ��: ֤ȯ��ծ=0
		--��ȯҵ��: ֤ȯ��ծ=��ծ���=[debtAmount]
	ISNULL(֤ȯ�ʲ�,0) AS ֤ȯ�ʲ�,
		--֤ȯ�ʲ�=��CASH���ʲ�
	ISNULL(�ֽ��ʲ�,0) AS �ֽ��ʲ�,
		--֤ȯ�ʲ�=CASH���ʲ�
	ISNULL(֤ȯ��ծ,0)+ISNULL(�ֽ�ծ,0) AS �ܸ�ծ,
	ISNULL(֤ȯ�ʲ�,0)+ISNULL(�ֽ��ʲ�,0) AS ���ʲ�,
	--case �ֽ�ծ	when NULL Then 0 else �ֽ�ծ	END �ֽ�ծ,
	--case ֤ȯ��ծ	when NULL Then 0 else ֤ȯ��ծ	END ֤ȯ��ծ,
	--case ֤ȯ�ʲ� 	when NULL Then 0 else ֤ȯ�ʲ�	END ֤ȯ�ʲ�,
	--case �ֽ��ʲ�	when NULL Then 0 else �ֽ��ʲ�	END �ֽ��ʲ�,
	--���屾��+�ֽ�ծ as �ܸ�ծ,
	--֤ȯ�ʲ�+�ֽ��ʲ� as ���ʲ�,
	(ISNULL(֤ȯ�ʲ�,0)+ISNULL(�ֽ��ʲ�,0))/(ISNULL(֤ȯ��ծ,0)+ISNULL(�ֽ�ծ,0)) as ά�ֵ�������
	FROM
	(
		SELECT C.clientid,C.����,C.���屾��,C.�ֽ�ծ,C.֤ȯ��ծ
		--,D.full_name AS �ͻ�ȫ�� 
		FROM
		(		SELECT clientid,
					dept as ����,					
					SUM(notional) ���屾��,									
					sum(CASE   assettype 
					when 'RZRQ_0' THEN debt
					when 'RZRQ_1' THEN debtInterest
					END)  as �ֽ�ծ,
					sum(CASE   assettype 
					when 'RZRQ_0' THEN  0			--����
					when 'RZRQ_1' THEN debtAmount   --��ȯ
					END)  as ֤ȯ��ծ
				FROM
				Credit_DB.C_position.acc_balance_contract
				WHERE balance_date=@BalanceDate
				AND LEFT(assettype,4)='RZRQ'
				GROUP BY clientid,dept
			) AS C
			--left join [Credit_DB].[C_client].[client_info] as D
			--on C.clientid=D.client_id
			
	) AS A
	LEFT JOIN
	(
			SELECT clientid,
				sum(CASE   cltr_assettype
				WHEN null THEN 0
				WHEN 'CASH' THEN 0 
				WHEN 'CASHFUND' THEN 0 
				ELSE cltr_value
				END) AS ֤ȯ�ʲ�,
				sum(CASE  when cltr_assettype in ( 'CASHFUND','CASH') THEN cltr_value
				END) AS �ֽ��ʲ�
			FROM 
			Credit_DB.C_position.acc_balance_collateral	
			WHERE balance_date=@BalanceDate
			AND assettype='RZRQ'
			GROUP BY clientid
	) AS B
	ON A.clientid=B.clientid

	
)




GO
