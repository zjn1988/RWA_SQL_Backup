USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_SecuCCR_Cltr]    Script Date: 2016/2/24 13:09:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-09,,>
-- Description:	<>
-- =============================================
CREATE FUNCTION [RWA].[get_SecuCCR_Cltr]
( 
	@BalanceDate DATE

	)

RETURNS TABLE 
AS
RETURN 
(

--declare @balancedate datetime
--set @balancedate='2015-11-30'

select @BalanceDate Balance_Date
	,ҵ������
	,ҵ������+�ͻ���� as �������ʶ����
	,b.֤ȯ����
	,֤ȯ����
	,֤ȯ��ֵ
	,��������

	,case 
		when b.֤ȯ���� in('Bond','CVBONDS') then 10
		when b.֤ȯ���� ='FUND' then 
			case when cast(�վ��ɽ��� as numeric(18,4))=0 then 60 
				else case when ֤ȯ����/cast(�վ��ɽ��� as numeric(18,4))/0.2*1<10 then 10
						when  ֤ȯ����/cast(�վ��ɽ��� as numeric(18,4))/0.2*1>60 then 60
					else ֤ȯ����/�վ��ɽ���/0.2*1 end end 
		when b.֤ȯ����='STOCK' then 
			case when cast(���̼� as numeric(18,4))=0 or cast(�վ��ɽ��� as numeric(18,4))=0 then 60 
				else case when ������� is null or datediff(day,@balancedate,�������)<0 then case when ֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1<10 then 10
																								  when ֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1>60 then 60
																								  else ֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1 end
						else case when (֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1+datediff(day,@balancedate,�������))<10 then 10 
						    when (֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1+datediff(day,@balancedate,�������))>60 then 60 
							else (֤ȯ��ֵ/���̼�/�վ��ɽ���/0.2*1+datediff(day,@balancedate,�������)) end end end 
		when b.֤ȯ����='INDEX' then 10
		else 60 end as ����������
	
	,case when ֤ȯ��ֵ>0 then ֤ȯ��ֵ*����������� else 0 end as ���Կۼ�
	,case when ֤ȯ��ֵ>0 then ֤ȯ��ֵ*����ۿ� else 0 end as �ۼ�����
	,case when ֤ȯ��ֵ>0 then ֤ȯ��ֵ*��С�ۿ� else 0 end as �ۼ�����

  

from
(			
		select �ͻ����,ҵ������,case when ֤ȯ���� is null then '000300.SH' else ֤ȯ���� end as ֤ȯ����
			,sum(֤ȯ����) as ֤ȯ����,sum(֤ȯ��ֵ) as ֤ȯ��ֵ 
		from position_db.rwa.get_TRS_ContractDtl(@balancedate) group by ҵ������,�ͻ����,֤ȯ����
	union all 
		select clientid,ҵ������,֤ȯ����,sum(֤ȯ����),sum(֤ȯ��ֵ) 
		from position_db.rwa.get_RZRQ_Dtl(@balancedate) group by ҵ������,clientid,֤ȯ����
	union all 
		select distinct �ϲ����д���,'STOCKPDG' ҵ������,��Ѻȯ����,sum(��Ѻȯ����),sum(��Ѻȯ��ֵ) 
		from position_db.rwa.get_CR_STOCKPDG_Cltr(@balancedate)v  group by �ϲ����д���,��Ѻȯ����
	union all 
		select ��Լ����,ҵ������,��Ѻȯ����,sum(��Ѻȯ����),sum(��ѺȨ��ֵ) 
		from position_db.rwa.get_AGREPO(@balancedate) group by ��Լ����,ҵ������,��Ѻȯ����	
)a	
left join
(
	select ֤ȯ����,֤ȯ����,��������,�վ��ɽ���,���̼�,�����������,����ۿ�,��С�ۿ�,����
	from position_db.rwa.SecuCCR_SecuAdj where Balance_Date=@Balancedate
)b	
	on a.֤ȯ����=b.֤ȯ���� or (right(b.֤ȯ����,2)='OF'and left(a.֤ȯ����,6)=b.����)
left join 
(
	SELECT trade_id,RELIEVE_DATE ������� FROM EDM_BASE.BF_ZX_RPM.VSRP_TRADE_INFO WHERE upddate_time=@balancedate
)c	
	on a.�ͻ����=c.trade_id
	


)









GO
