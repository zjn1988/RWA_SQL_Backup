USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_AccInfo]    Script Date: 2016/2/24 11:14:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-12-03,,>
-- Description:	<������˻���Ϣ,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_AccInfo]
( 

@Balancedate DateTime

)

RETURNS TABLE 
AS
RETURN 
(

select *,case category
when 	'��˾-�ƲƲ�'	then	'1001'
when '��˾-����' then '1002'
when 	'��˾-����'	then	'1004'
when 	'��˾-Ͷ�ʹ���'	then	'1003'
when 	'����-ETF����'	then	'0304'
when 	'����-��Ʊ��Ѻ�ع�'	then	'0301'
when 	'����-���������'	then	'0306'
when 	'����-����TRS'	then	'0303'
when 	'����-��������'	then	'0307'
when 	'����-��Ȩ����'	then	'0305'
when 	'����-����'	then	'0309'
when 	'����-������'	then	'0308'
when 	'����-Լ������'	then	'0302'
when 	'����-�Ƹ�����'	then	'0102'
when 	'����-�в�Ͷ��'	then	'0104'
when 	'����-����'	then	'0101'
when 	'����-����'	then	'0103'
when 	'Ȩ��Ͷ��-����'	then	'0501'
when    'Ȩ��Ͷ��-�ض�Ͷ��' then '0501'  --��2015��12��31��������
when 	'Ȩ��Ͷ��-��Ʊ����'	then	'0502'  --��2016��1����ӡ����ס��ĳɡ�Ȩ��Ͷ�ʡ�
when    'Ȩ��Ͷ��-Ӧ��'	then	'0503'
when 	'����-FOF'	then	'0401'
when 	'����-MOM'	then	'0402'
when 	'����-��������'	then	'0403'
when 	'����-��Ȩ��Ӫ'	then	'0404'
when 	'����-Ӧ��'	then	'0405'
when 	'������-������'	then	'0601'
--when 	'Ӧ��-Ȩ��Ͷ��'	then	'0601'
--when 	'Ӧ��-����'	then	'0602'
when 	'֤��-��ȨͶ��'	then	'0205'
when 	'֤��-����TRS'	then	'0202'
when 	'֤��-��ȯ��'	then	'0203'
when 	'֤��-������ȯ'	then	'0201'
when 	'֤��-���ӻ���'	then	'0206'
when   '֤��-�����Թ���' then '0204'
when 	'�ʽ�-����'	then	'0901'
when 	'�ʽ�-����'	then	'0902'
when 	'�ʽ�-����'	then	'0903'
when 	'�ʽ�-����'	then	'0904'
when    '�ʽ�-��ծ����' then '0905'
when '����' then '0700'
else '9999' end	 ��ϴ���
,case deptname 
when 	'����'	then	'0100'
when 	'֤��'	then	'0200'
when 	'����'	then	'0300'
when 	'����'	then	'0400'
when 	'Ȩ��Ͷ��'	then	'0500'
when 	'������'	then	'0600' --2016��֮ǰ��"Ӧ���˻�" ͳһ��Ϊ"������",��������Ӧ��
when 	'����'	then	'0700'
when 	'�ʽ�'	then	'0900'
when 	'��˾'	then	'1000'
else '9999'end ���Ŵ���
,'0000' as ��˾����
from(select subaccid,invarlimit,incompany,subaccname
	,case when deptname='����' then deptname else deptname+'-'+category end category
	,deptname
from(select subaccid,invarlimit,incompany,subaccname
	,case when subaccid='ZJBZJJ'then '���ӻ���' 
		when subaccid in ('YYB-JJ','YYB-DX') then '����' 
		when subaccid in ('ZYBH2701','DKTR0401') then '����'
		when category='JYSDEV' then '����'
		--when deptname='����'and category='Ӧ��' then '����'
		--when deptname='����'and category='Ӧ��' then '����'
		when deptname='GSYW' and subaccid not in ('TZGLB','JCB') then '����'
		when deptname='DZSP' then '����'
		when category in ('MOMCTA','MOM���') then 'MOM'
		when category ='JCB' then '�ƲƲ�'
		when category ='TZGLB' then 'Ͷ�ʹ���'
		when category ='���ڽ���' then '����'
		else category end as category
	,case when subaccid='ZJBZJJ'then '֤��'
		when subaccid in ('YYB-JJ','YYB-DX') then '�ʽ�'
		when subaccid in ('ZYBH2701','DKTR0401') then '����' 
		when category='JYSDEV' then '����' 
		when deptname='�в�Ͷ��' then '����'
		when deptname='DZSP' then '����'
		when deptname='GSYW' then '��˾'
		--when category='Ӧ��' then 'Ӧ��'
		when deptname='����' then '��˾'
		else deptname end as deptname

from
(
	select subaccid,invarlimit,inCompany
	,case when stratname is null then (case when subaccname is null then subaccid else subaccname end) else stratname end as subaccname
	,case when category is null then (case when inneraccname is null or len(inneraccname)=0 then accid else inneraccname end) else category end as category
	,case when Dept is null then (case when deptname is null or len(DeptName)=0then deptid else deptname end) else dept end as deptname

	from
	(
		select a.subaccid,a.accid,deptid,invarlimit,incompany,stratname,category,dept,subaccname,inneraccname,deptname
		from
		(
			select distinct right(Account,len(account)-patindex('%;%',Account)) as SubAccId
			,left(Account,patindex('%;%',Account)-1) as AccId
			,dept as DeptId 
			from [Position_DB].[hld].[PurePosition]where [BALANCE_DATE] = @BalanceDate
		)a
		left join
		(
			select subaccid,invarlimit,inCompany	from [Position_DB].[config].[AccountDeptMap1]
		)b
		on a.Subaccid=b.subaccid
		left join
		(
			SELECT  distinct accid,stratname,category,dept
			FROM    MarketRisk.Report.fn_market_calculateAccountPnlSeriesQsQuickCNY(@Balancedate,@Balancedate,'*')
			where category<>'TRS'
		) as equity
		on a.subaccid=equity.accid
		left join position_db.config.accountdeptmap_zq  fi
		on a.subaccid=fi.subaccid
	)totalefi

	where (InCompany=1 or subaccid in ('DKTR0401' ,'ZYBH2701'))--���ڹ�˾�ڲ��˻�,����͸���ʲ��������ӹ�˾
	and SubAccId<>'Dacheng' --�������͸��ľ����ʲ�,Ŀǰ���ݲ�׼
	and AccId <> 'BX'--����
	and subaccid <> 'YSPKJJY' --���ܲ��羳��������������Ϣ��ȫ
	and subaccid <> 'YSPHGTCS' --���ܲ�����ͨ���Ի�����С���ӣ��г���Ҳ����

	/* ���м���*/
	and AccId <> 'SWAP' --���滥��
	and SubAccId <> 'ZJBJNH' --���滥��
	and Subaccid <> 'JYSGH2' --���滥��
	and Subaccid <> 'GPZYHG' --���ܹ�Ȩ��Ѻ�ع�

	/* �ѶԳ����*/
	and Subaccid <> 'JYBJGR' --���ܽṹ�����ʷ����ѶԳ�
	and SubAccId <> 'YSP-CWQQ' --���ܲ�������Ȩ�����ѶԳ�
	and subaccid <> 'YSKJHH'--���ܲ����������ѶԳ�
	and SubAccId <> 'TZGLB-SYQZC' --Ͷ�ʹ�������Ȩת���˻�----->?
	and Subaccid <> 'F_A002' --����������˻��Գ���˻�
	and Subaccid <> 'YSPET2' --��һ����CSI��RQFII��ETF�Գ�		
)c)d)e
   
)





GO
