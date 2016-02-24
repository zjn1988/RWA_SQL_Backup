USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_Others]    Script Date: 2016/2/24 11:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_Others]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(
/*

10���ֽ������
20��ծȯ
30��������Ʊ
40����������
50����Ʒ
41����Ʒ
31��������
32�����ڹ�Ʊ�����¡�������
42�����ڻ���
49��������ģ�ͷ�
50: ������Ʒ

*/



/*  ���ղ�Զ�����ֻ��Գ� (ֻ�㲿�Ų���û�е������� )  */   

(select c.*, case when secucode like 'SAC%' then 41 else 20 end ��׼�����
--balance_date,accid,secucategory,secucode,quantity,b.Underlying,UnderlyingMarket,CounterpartyName
from
	(
		select distinct underlying 
		from (
			select --,accid,subaccid,��ϴ���
				distinct underlying,sum(case secucategory when 'bond' then quantity*100 else quantity end) Quantity 
				,balance_date
			from position_db.rwa.mRWA_all 
			where RWA��Ч��<>1 and accid like '%����%'
			and balance_date=@BalanceDate
			and underlying not in ('511990','519507','519118','160609','161615','550011','000425','000543','000665')
			--�޳����л����Ի��𣬴˴���Ҫ�Ż������ӻ�������ֶ�			
			group by underlying,balance_date
		)a 
		where quantity>1 or quantity<-1
	)b
	left join	
	(
		select * from position_db.rwa.mRWA_all where RWA��Ч��<>1 and accid like '%����%'and balance_date=@BalanceDate
	)c
		on b.underlying=c.underlying 
		


)union all(




/*  ��׼���������ա����ڣ�����*/   
select
	*
	,case when SecuCategory ='Cash'or fundtype='�����г��ͻ���' then 10  --�ֽ�����
		when SecuCategory ='Bond' then 20   --δ����ծȯ��ΥԼծȯ��
		when SecuCategory ='Equity' then case when SecuMarket='Neeq' then 31  --������
									else case when AccId like '%����%' or SubAccid='YYB-DX' then 32 --��Ʊ���¡�����
											else case when right(secucode,1) not in ('1','2','3','4','5','6','7','8','9','0') 
														or left(secucode,1) not in ('1','2','3','4','5','6','0','8')  then 41  --��Ʒ
												 else 30 end 
											end --������Ʊ
									end
		else case when  SecuCategory in ('ETF','Fund') then 
						case when right(secucode,1) not in ('1','2','3','4','5','6','7','8','9','0') 
								or left(secucode,1) not in ('1','2','3','4','5','6','0','8')  then 41  --��Ʒ
						else case when SubAccId='YYB-JJ' then 42  --���ڻ���
								when Accid like '%��Ʊ����%' then 49 --�����ر�׼������
								else 40 end --�������� 
						end end
		end as ��׼�����					

from position_db.rwa.mRWA_all 
where RWA��Ч��<>1 and accid not like '%����%' and accid not like '%����%' 
and balance_date=@BalanceDate


)union all(


select f.*, 50 ��׼�����
from
	(
		select distinct underlying 
		from (
			select distinct underlying,sum(quantity) Quantity,balance_date
			from position_db.rwa.mRWA_all 
			where RWA��Ч��<>1 and accid like '%����%'
			and balance_date=@BalanceDate
			group by underlying,balance_date
		)d 
		where quantity>1 or quantity<-1
	)e
	left join	
	(
		select *
		from position_db.rwa.mRWA_all
		where RWA��Ч��<>1 and accid like '%����%'
			and balance_date=@BalanceDate
	)f
		on e.underlying=f.underlying 


))















GO
