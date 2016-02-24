USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_SecuAdj]    Script Date: 2016/2/24 13:10:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_SecuAdj]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select Balance_Date,֤ȯ����,����,�г�,֤ȯ����,֤ȯ����,��������
	,isnull(�վ��ɽ���,0) �վ��ɽ���
	,isnull(���̼�,0) ���̼�

		,case ֤ȯ���� when 'Fund' then case when right(֤ȯ����,1)='B' then 0.7 when right(֤ȯ����,1)='A' then 0
								else case when ֤ȯ���� like '%����300%' then 0  --׷������ָ���Ĳ�Ϊ0
												when ����Ͷ������ in ('�����г��Ի���','ծȯ�ͻ���') then 0
												when ����Ͷ������ in ('����Ͷ�ʻ���') then 0.1
											else 0.05 end end  
					when 'Stock' then case when ��������>Balance_Date then 0.1  --�¹ɵ�����,90%,��骸����۹�
											when DATEDIFF(day,���������,@Balancedate)>=365 then 0.7 --������ͣ��1������
											when ֤ȯ���� like '%ST%' then 0.7 --ST��Ʊ
											else (case when left(֤ȯ����,3) in ('002','003') then 1 else 0 end --(1)��С��
													+case when isnull(��ͨA��,0)*isnull(���̼�,0)<1500000000 then 1 else 0 end --(2)��ͨ��ֵС��15��
													+case when DATEDIFF(day,���������,@Balancedate)>=30 then 1 else 0 end --(3)������ͣ��30������
													+case when ROE1<0 then 1 else 0 end 
													+case when �о��� is null then 0 else --�о���ֻ�������Ĳ���,Ϊ�����Զ����������Ĵ�����,������
													case when cast(�о��� as numeric(18,4))>cast(������ҵ�о��� as numeric(18,4)) 
													and cast(�о��� as numeric(18,4))<(2*cast(������ҵ�о��� as numeric(18,4)) ) then 1 else 0 end end
									)*0.05 
									+(case when ROE1<0 and ROE2<=0 then 1 else 0 end 
									+case when �о��� is null then 1 else case when cast(�о��� as numeric(18,4))>(2*cast(������ҵ�о��� as numeric(18,4))) then 1 else 0 end end
									)*0.1 end 
				 when 'CVBonds' then case when ����ծ������ ='AAA' or ����ծ������ is null	then 0.05 else 0.1 end 
				 when 'Bond' then case when ����ծ������ =	'AAA' or ����ծ������ is null	then	0
						when ����ծ������ in ('AA+','AA')	then	0.05  else 0.1 end 
				when 'index' then 0.1 --���Ϊindex�Ķ���û����д֤ȯ�ģ���һ������
				else 0 end 
				+�ֹ��������� 
				as �����������

		,case when �о��� is null then 0.7 else 
				case when (1-1*(0.9/cast(�о��� as numeric(18,4))))<0.7 then 0.7 
					else (1-1*(0.9/cast(�о��� as numeric(18,4)))) end end as ����ۿ�
		,case when ֤ȯ����='STOCK' then 0.25 else 0.05 end as ��С�ۿ�

		

from	(select * from position_db.rwa.secuCCR_SecuInfo where balance_date=@BalanceDate 
)a left join (SELECT left(curvenamecn,len(curvenamecn)-4) as ������ҵ,tagValueStr ������ҵ�о��� 
from ZX_AUDIT.zx_mkt.v_tag_info_1 where tagName = 'PE_PB_LF_SYWG_INDUSTRY_1' and balanceDate = @balancedate
) b on a.������ҵ=b.������ҵ








)









GO
