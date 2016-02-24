USE [Position_DB]
GO
/****** Object:  StoredProcedure [RWA].[update_SecuCCR_Netting]    Script Date: 2016/2/24 11:09:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,ZHANGJIANNAN>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RWA].[update_SecuCCR_Netting]
	-- Add the parameters for the stored procedure here
	@BalanceDate datetime
as
	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MaxID int;
	declare @UpdateTime datetime;

	delete from Position_DB.[RWA].SecuCCR_Netting Where balance_date=@BalanceDate ;
	set @UpdateTime=(select GETDATE());
	------------------------------------------------------------------------------------
	--���±��
	select * into #TEMP from Position_DB.[RWA].SecuCCR_Netting;
	DELETE  FROM Position_DB.[RWA].SecuCCR_Netting
	insert into Position_DB.[RWA].SecuCCR_Netting(
		[ID],[UpdateTime],Balance_Date,����������,ҵ������,����,�ͻ�,���屾��,�ܸ�ծ
		,���ʲ�,ά�ֵ�������,ʣ������,���Կۼ�,�����ۼ�,�ۼ�����,�ۼ�����,���ռ�ֵ�ۼ�
		,RWA�ȼ�������,RWA������ʲ�,�����ά�ֵ�������	,�����ճ���	,���������ȼ�,��������
		,PD,ULPD,LGD,���޵���,Ԥ����ʧ,��Ԥ����ʧ,�����ڷ���Ȩ��,RWA,���ճ���ռ��,Ԥ����ʧռ��
		,��Ԥ����ʧռ��,RWAռ��
		)
	SELECT 
		(ROW_NUMBER() OVER (ORDER BY [UpdateTime] ASC)) AS ID
		,[UpdateTime],Balance_Date,����������,ҵ������,����,�ͻ�,���屾��,�ܸ�ծ
		,���ʲ�,ά�ֵ�������,ʣ������,���Կۼ�,�����ۼ�,�ۼ�����,�ۼ�����,���ռ�ֵ�ۼ�
		,RWA�ȼ�������,RWA������ʲ�,�����ά�ֵ�������	,�����ճ���	,���������ȼ�,��������
		,PD,ULPD,LGD,���޵���,Ԥ����ʧ,��Ԥ����ʧ,�����ڷ���Ȩ��,RWA,���ճ���ռ��,Ԥ����ʧռ��
		,��Ԥ����ʧռ��,RWAռ��
	 FROM #TEMP
	 drop table #TEMP

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
	from position_db.rwa.get_secuccr_Netting(@BalanceDate)
	--from(	
	--	select *
	--		,��Ԥ����ʧ*12.5 RWA
	--		,case when �ܸ�ծ=0 then 0 else �����ճ���/�ܸ�ծ end ���ճ���ռ��
	--		,case when �ܸ�ծ=0 then 0 else Ԥ����ʧ/�ܸ�ծ end Ԥ����ʧռ��
	--		,case when �ܸ�ծ=0 then 0 else ��Ԥ����ʧ/�ܸ�ծ end ��Ԥ����ʧռ��
	--		,case when �ܸ�ծ=0 then 0 else ��Ԥ����ʧ/�ܸ�ծ*12.5 end RWAռ��
	
	--	from(	select *
	--			,�����ճ���*PD*LGD*���޵��� Ԥ����ʧ
	--			,�����ճ���*ULPD*LGD*���޵��� ��Ԥ����ʧ
	--			,ULPD*LGD*���޵���*12.5 �����ڷ���Ȩ��

	--		from(	select e.*
	--				,v.PD
	--				,case �������� when '����' then IndivULPD when '����' then BankULPD else CompULPD end ULPD
	--				,0.6 LGD
	--				,ʣ������/365*mAdjust1+mAdjust2 ���޵���

	--			from(	select *
	--					,case when ���ʲ�=0 then 0 else ���ռ�ֵ�ۼ�/���ʲ�*1 end RWA�ȼ�������
	--					,���ʲ�-���ռ�ֵ�ۼ� RWA������ʲ�
	--					,case when �ܸ�ծ=0 then 0 else (���ʲ�-���ռ�ֵ�ۼ�)/�ܸ�ծ*1 end  �����ά�ֵ�������
	--					,case when ���ʲ�<=0 then 0 else case when ���ʲ�-���ռ�ֵ�ۼ�>�ܸ�ծ then 0 else �ܸ�ծ-���ʲ�+���ռ�ֵ�ۼ� end end �����ճ���
	--					,'Z-B5' as ���������ȼ�
	--					,'ͨ��' as ��������

	--				from(
	--					select *
	--						,case when ���ʲ�<0 then 0 else case when ���Կۼ�+�����ۼ�>�ۼ����� then �ۼ�����
	--															when ���Կۼ�+�����ۼ�<�ۼ����� then �ۼ�����
	--															else ���Կۼ�+�����ۼ� end end ���ռ�ֵ�ۼ�
	
	--					from(	select balance_date,����������,ҵ������,����,�ͻ�
	--							,���屾��,�ܸ�ծ,���ʲ�,ά�ֵ�������,ʣ������
	--							,isnull(���Կۼ�,0) ���Կۼ�
	--							,isnull(SVaR,0) as �����ۼ�
	--							,isnull(�ۼ�����,���ʲ�) �ۼ�����,isnull(�ۼ�����,0) �ۼ�����
	
	--						from (
	--							select ������ as balance_date, �ͻ���� ����������,ҵ������,�˻����� ����,�ͻ���� �ͻ�
	--								,sum(���屾��) ���屾��,sum(�ܸ�ծ) �ܸ�ծ,sum(���ʲ�) ���ʲ�,case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end ά�ֵ�������,0.5 ʣ������ 
	--							from position_db.rwa.get_TRS_ContractInfo(@balancedate) 
	--							group by ������,�ͻ����,ҵ������,�˻�����
	--						union all 
	--							select ������, clientid,ҵ������,����,clientid,sum(���屾��),sum(�ܸ�ծ),sum(���ʲ�),case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end,0.5
	--							from position_db.rwa.get_RZRQ(@balancedate)  
	--							group by ������, clientid,ҵ������,����,clientid
	--						union all 
	--							select ������,�ϲ����д���,ҵ������,����,�ϲ����пͻ�,sum(���屾��),sum(�ܸ�ծ),sum(���ʲ�)
	--								,case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end, datediff(day,@balancedate,�ϲ����к�Լ������)
	--							from position_db.rwa.get_CR_STOCKPDG_Cont(@balancedate)  
	--							group by ������,�ϲ����д���,ҵ������,����,�ϲ����пͻ�,�ϲ����к�Լ������
	--						union all 
	--							select ������,��Լ����,ҵ������,����,�ͻ�����,sum(���屾��),sum(�ܸ�ծ),sum(��ѺȨ��ֵ+�ֽ��ʲ�)
	--										,case when sum(�ܸ�ծ)<=0 then 0 else sum(��ѺȨ��ֵ+�ֽ��ʲ�)/sum(�ܸ�ծ)*1 end, datediff(day,@balancedate,��Լ������)
	--							from position_db.rwa.get_AGREPO(@balancedate)  
	--							group by ������,��Լ����,ҵ������,����,�ͻ�����,��Լ������
	--						)a 
	--						left join 
	--						(
	--							select �������ʶ����,sum(����������*֤ȯ��ֵ)/sum(֤ȯ��ֵ)*1 �������������
	--								,sum(���Կۼ�) ���Կۼ�,sum(�ۼ�����) �ۼ�����,sum(�ۼ�����) �ۼ�����
	--							from Position_DB.rwa.SecuCCR_Cltr 
	--							where Balance_Date=@balancedate 
	--							group by �������ʶ����
	--						)b
	--							on a.ҵ������+a.����������=b.�������ʶ����
	--						left join
	--						(
	--							select SVaR,ʶ���� 
	--							from Position_DB.rwa.SecuCCR_SVaRInfo 
	--							where Balance_Date=@BalanceDate
	--						)h
	--							on a.ҵ������+a.����������=h.ʶ����
	--					)c 
	--				)d 
	--			)e left join position_db.rwa.parameter_ULPDMatrix() v
	--			on e.���������ȼ�=v.InnerRating
	--		)f
	--	)g
	--) as zz

END





GO
