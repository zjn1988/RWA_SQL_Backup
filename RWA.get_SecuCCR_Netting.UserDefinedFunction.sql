USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_Netting]    Script Date: 2016/2/24 13:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_Netting]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(



select *
		,�����ճ���*PD*LGD*���޵��� Ԥ����ʧ
		,�����ճ���*ULPD*LGD*���޵��� ��Ԥ����ʧ
		,ULPD*LGD*���޵���*12.5 �����ڷ���Ȩ��
		,�����ճ���*ULPD*LGD*���޵���*12.5 RWA
		,case when �ܸ�ծ=0 then 0 else �����ճ���/�ܸ�ծ end ���ճ���ռ��
		,case when �ܸ�ծ=0 then 0 else �����ճ���*PD*LGD*���޵���/�ܸ�ծ end Ԥ����ʧռ��
		,case when �ܸ�ծ=0 then 0 else �����ճ���*ULPD*LGD*���޵���/�ܸ�ծ end ��Ԥ����ʧռ��
		,case when �ܸ�ծ=0 then 0 else �����ճ���*ULPD*LGD*���޵���/�ܸ�ծ*12.5 end RWAռ��
		
	from(	
		select *
				,case when ���ʲ�=0 then 0 else ���ռ�ֵ�ۼ�/���ʲ�*1 end RWA�ȼ�������
				,���ʲ�-���ռ�ֵ�ۼ� RWA������ʲ�
				,case when �ܸ�ծ=0 then 0 else (���ʲ�-���ռ�ֵ�ۼ�)/�ܸ�ծ*1 end  �����ά�ֵ�������
				,case when ���ʲ�<=0 then 0 else case when ���ʲ�-���ռ�ֵ�ۼ�>�ܸ�ծ then 0 else �ܸ�ծ-���ʲ�+���ռ�ֵ�ۼ� end end �����ճ���
				,0.6 LGD
				,CompULPD ULPD
				,ʣ������/365*mAdjust1+mAdjust2 ���޵���
		from(
					select balance_date,����������,ҵ������,����,�ͻ�,'Z-B5' as ���������ȼ�,'ͨ��' as ��������
						,���屾��,�ܸ�ծ,���ʲ�,ά�ֵ�������,ʣ������
						,isnull(���Կۼ�,0) ���Կۼ�
						,isnull(SVaR,0) as �����ۼ�
						,isnull(�ۼ�����,���ʲ�) �ۼ�����,isnull(�ۼ�����,0) �ۼ�����
						,case when ���ʲ�<0 then 0 else case when isnull(���Կۼ�,0)+isnull(SVaR,0)>isnull(�ۼ�����,���ʲ�) then isnull(�ۼ�����,���ʲ�)
														when isnull(���Կۼ�,0)+isnull(SVaR,0)<isnull(�ۼ�����,0) then isnull(�ۼ�����,0)
														else isnull(���Կۼ�,0)+isnull(SVaR,0) end end ���ռ�ֵ�ۼ�
	
					from (
							select ������ as balance_date, �ͻ���� ����������,ҵ������,�˻����� ����,�ͻ���� �ͻ�
								,sum(���屾��) ���屾��,sum(�ܸ�ծ) �ܸ�ծ,sum(���ʲ�) ���ʲ�,case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end ά�ֵ�������,0.5 ʣ������ 
							from position_db.rwa.get_TRS_ContractInfo(@balancedate) 
							group by ������,�ͻ����,ҵ������,�˻�����
						union all 
							select ������, clientid,ҵ������,����,clientid,sum(���屾��),sum(�ܸ�ծ),sum(���ʲ�),case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end,0.5
							from position_db.rwa.get_RZRQ(@balancedate)  
							group by ������, clientid,ҵ������,����,clientid
						union all 
							select ������,�ϲ����д���,ҵ������,����,�ϲ����пͻ�,sum(���屾��),sum(�ܸ�ծ),sum(���ʲ�)
								,case when sum(�ܸ�ծ)<=0 then 0 else sum(���ʲ�)/sum(�ܸ�ծ)*1 end, datediff(day,@balancedate,�ϲ����к�Լ������)
							from position_db.rwa.get_CR_STOCKPDG_Cont(@balancedate)  
							group by ������,�ϲ����д���,ҵ������,����,�ϲ����пͻ�,�ϲ����к�Լ������
						union all 
							select ������,��Լ����,ҵ������,����,�ͻ�����,sum(���屾��),sum(�ܸ�ծ),sum(��ѺȨ��ֵ+�ֽ��ʲ�)
										,case when sum(�ܸ�ծ)<=0 then 0 else sum(��ѺȨ��ֵ+�ֽ��ʲ�)/sum(�ܸ�ծ)*1 end, datediff(day,@balancedate,��Լ������)
							from position_db.rwa.get_AGREPO(@balancedate)  
							group by ������,��Լ����,ҵ������,����,�ͻ�����,��Լ������
						)a 
						left join 
						(
							select �������ʶ����,sum(����������*֤ȯ��ֵ)/sum(֤ȯ��ֵ)*1 �������������
								,sum(���Կۼ�) ���Կۼ�,sum(�ۼ�����) �ۼ�����,sum(�ۼ�����) �ۼ�����
							from Position_DB.rwa.SecuCCR_Cltr 
							where Balance_Date=@balancedate 
							group by �������ʶ����
						)b
							on a.ҵ������+a.����������=b.�������ʶ����
						left join
						(
							select SVaR,ʶ���� 
							from Position_DB.rwa.SecuCCR_SVaRInfo 
							where Balance_Date=@BalanceDate
						)h
						on a.ҵ������+a.����������=h.ʶ����
		)c
		left join position_db.rwa.parameter_ULPDMatrix() v
		on ���������ȼ�=v.InnerRating
	)d

)











GO
