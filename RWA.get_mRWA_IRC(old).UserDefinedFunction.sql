USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_mRWA_IRC(old)]    Script Date: 2016/2/24 11:17:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-16,������2015-12-02>
-- Description:	<����г����ռ����������յĳֲ�����,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_mRWA_IRC(old)]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(


select 
	@BalanceDate as Balance_Date
	,IRCType,RiskFactor,Issuer,RatingOrder,SysFactor,IdoFactor,MK_Duration,DurationOrder
	,(case IRCType when 'Bond' then (case RatingOrder
	when 	1	then ( case DurationOrder when	1	then	 0.0008 	
			when	2	then	 0.0007 	
			when	3	then	 0.0011 	
			when	4	then	 0.0015 	
			when	5	then	 0.0019 	
			when	6	then	 0.0034 	
			else			 0.0049 	end)
	when 	2	then ( case DurationOrder when	1	then	 0.0015 	
			when	2	then	 0.0017 	
			when	3	then	 0.0023 	
			when	4	then	 0.0032 	
			when	5	then	 0.0040 	
			when	6	then	 0.0053 	
			else		 0.0066 	end)
	when 	3	then ( case DurationOrder when	1	then	 0.0019 	
			when	2	then	 0.0022 	
			when	3	then	 0.0031 	
			when	4	then	 0.0042 	
			when	5	then	 0.0052 	
			when	6	then	 0.0069 	
			else		 0.0082 	end)
	when 	4	then ( case DurationOrder when	1	then	 0.0034 	
			when	2	then	 0.0041 	
			when	3	then	 0.0056 	
			when	4	then	 0.0075 	
			when	5	then	 0.0093 	
			when	6	then	 0.0119 	
			else		 0.0136 	end)
	when 	5	then ( case DurationOrder when	1	then	 0.0106 	
			when	2	then	 0.0122 	
			when	3	then	 0.0155 	
			when	4	then	 0.0189 	
			when	5	then	 0.0223 	
			when	6	then	 0.0269 	
			else		 0.0290 	end)
	when 	6	then ( case DurationOrder when	1	then	 0.0138 	
			when	2	then	 0.0164 	
			when	3	then	 0.0220 	
			when	4	then	 0.0273 	
			when	5	then	 0.0324 	
			when	6	then	 0.0380 	
			else		 0.0404 	end)
			else ( case DurationOrder when	1	then	 0.0918 	
			when	2	then	 0.0864 	
			when	3	then	 0.0946 	
			when	4	then	 0.1003 	
			when	5	then	 0.1046 	
			when	6	then	 0.1061 	
			else		 0.1181 	end)end)else NULL end
	)as OriCDS
	,��˾�ܼ�,�̶����沿,���ս���,���ղƸ�����,��������,�в�Ͷ�ʲ�,�ʽ���Ӫ��,Ȩ��Ͷ�ʲ�,��Ʊ����,Ȩ��Ӧ��
	,����ҵ����,����Ͷ��ҵ����,��������,����Ӧ��,֤ȯ����ҵ����,֤��ȯ��,֤���Ȩ������,����


from
(
	select

	IRCType
	,a.��Ĵ��� as RiskFactor
	,MK_Duration

	,(case IRCType when 'Bond' then (case 
	when	MK_Duration	<	1 	then	1
	when	MK_Duration	<	2 	then	2
	when	MK_Duration	<	3 	then	3
	when	MK_Duration	<	4 	then	4
	when	MK_Duration	<	5 	then	5
	when	MK_Duration	<	7 	then	6
	else 7  end) else NULL end 
	)as DurationOrder

	,��ķ��з� as Issuer

	,(case ������ȫ
	when	'Z-A1'	then	1 --'Aaa'
	when	'Z-A2'	then	2 --'Aa'
	when	'Z-A3'	then	2 --'Aa'
	when	'Z-A4'	then	3 --'A'
	when	'Z-A5'	then	3 --'A'
	when	'Z-B1'	then	3 --'A'
	when	'Z-B2'	then	4 --'Baa'
	when	'Z-B3'	then	4 --'Baa'
	when	'Z-B4'	then	4 --'Baa'
	when	'Z-B5'	then	4 --'Baa'
	when	'Z-C1'	then	5 --'Ba'
	when	'Z-C2'	then	5 --'Ba'
	when	'Z-C3'	then	5 --'Ba'
	when	'Z-D'	then	6 --'B'
	else 7 end	--'Caa-C' 
	)as RatingOrder

	,(case ������ȫ
	when	'Z-A1'	then	 0.28571 
	when	'Z-A2'	then	 0.28096 
	when	'Z-A3'	then	 0.28096 
	when	'Z-A4'	then	 0.27539 
	when	'Z-A5'	then	 0.27539 
	when	'Z-B1'	then	 0.27539 
	when	'Z-B2'	then	 0.22997 
	when	'Z-B3'	then	 0.22997 
	when	'Z-B4'	then	 0.22997 
	when	'Z-B5'	then	 0.22997 
	when	'Z-C1'	then	 0.22108 
	when	'Z-C2'	then	 0.22108 
	when	'Z-C3'	then	 0.22108 
	when	'Z-D'	then	 0.14966 
	else 0.14400 end
	)as SysFactor

	,(case ������ȫ
	when	'Z-A1'	then	 0.95831 
	when	'Z-A2'	then	 0.95972 
	when	'Z-A3'	then	 0.95972 
	when	'Z-A4'	then	 0.96133 
	when	'Z-A5'	then	 0.96133 
	when	'Z-B1'	then	 0.96133 
	when	'Z-B2'	then	 0.97320 
	when	'Z-B3'	then	 0.97320 
	when	'Z-B4'	then	 0.97320 
	when	'Z-B5'	then	 0.97320 
	when	'Z-C1'	then	 0.97526 
	when	'Z-C2'	then	 0.97526 
	when	'Z-C3'	then	 0.97526 
	when	'Z-D'	then	 0.98874 
	else  0.98958 end
	)as IdoFactor

	,sum(MtM) as '��˾�ܼ�'
	,sum(case when ��� in( '���ս���', '��������','���ղƸ�����') then MtM else 0 end) as '�̶����沿'
	,sum(case ��� when '���ս���' then MtM else 0 end) as '���ս���'
	,sum(case ��� when '���ղƸ�����' then MtM else 0 end) as '���ղƸ�����'
	,sum(case ��� when '��������' then MtM else 0 end) as '��������'
	,sum(case ��� when '�в�Ͷ�ʲ�' then MtM else 0 end) as '�в�Ͷ�ʲ�'
	,sum(case ��� when '�ʽ���Ӫ��' then MtM  else 0 end) as '�ʽ���Ӫ��'
	,sum(case when ��� in( 'Ȩ��Ӧ��','��Ʊ����') then MtM else 0 end) as 'Ȩ��Ͷ�ʲ�'
	,sum(case when ��� ='Ȩ��Ӧ��'then MtM else 0 end) as 'Ȩ��Ӧ��'
	,sum(case when ��� ='��Ʊ����'then MtM else 0 end) as '��Ʊ����'
	,sum(case ��� when '����ҵ����' then MtM else 0 end) as '����ҵ����'
	,sum(case when ��� in('��������','����Ӧ��') then MtM else 0 end) as '����Ͷ��ҵ����'
	,sum(case when ��� ='��������' then MtM else 0 end) as '��������'
	,sum(case when ��� ='����Ӧ��' then MtM else 0 end) as '����Ӧ��'
	,sum(case when ��� in('֤��ȯ��','֤���Ȩ������') then MtM else 0 end) as '֤ȯ����ҵ����'
	,sum(case ��� when '֤��ȯ��' then MtM else 0 end) as '֤��ȯ��'
	,sum(case ��� when '֤���Ȩ������' then MtM else 0 end) as '֤���Ȩ������'
	,sum(case ��� when '����' then MtM else 0 end) as  '����'

	from
	(
		select 	��Ĵ���

			,(case AccId when 'FIJY' then '���ս���' when 'FIZJ' then '���ղƸ�����'
			when 'FIXS' then '��������'	when 'JYSDEV' then '����ҵ����' 
			else (case when DeptId= 'JCTZ' then  '�в�Ͷ�ʲ�' when DeptId = 'ZJYY' then '�ʽ���Ӫ��'
			when SubAccId = 'ZJBRQC' then '֤��ȯ��' when (DeptID='ZQJR'and SubAccId<>'ZJBRQC') then '֤���Ȩ������'
			when (AccId='JYSSTOCK'and SubAccId in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then 'Ȩ��Ӧ��'
			when (AccId='JYSSTOCK'and SubAccId not in ('QYTZ-YJBY','QYTZ-YJQSG','XYTZ-YJZY')) then '��Ʊ����'
			when (AccId='Quant'and SubAccId='LLTZ-YYZC')then '����Ӧ��'
			when (AccId='Quant'and SubAccId<>'LLTZ-YYZC') then  '��������'
			else '����' end) end) as ���

			, sum(case when SecuCategory in ('Bond','Equity','CVBond')then PresentValue_CNY else Notional end
			) as MtM

			,(case when SecuCategory in('Bond','FwdBond') then 'Bond' else 'Equity' end
			) as 'IRCType'

		from [Position_DB].[RWA].[mRWA_All] where Balance_Date=@BalanceDate
			and RWA��Ч��=1 
			and Underlying not in ('000300.SH','000016.SH','000905.SH')  --ָ��������IRC
			and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		group by ��Ĵ���,SECUCATEGORY,DeptID,AccID,SubAccId
	) as a
	left join 
	( 
		select ��Ĵ���
			,��ķ��з�
			,Grade
			,(case when ��ķ��з� is NULL then 'Z-B5' --�����Ʊ������!!!
			when ��ķ��з� like '%������%' then 'Z-A1' 
			when ��ķ��з� like '%��������%'then 'Z-A1'
			when ��ķ��з� like '%ũҵ��չ����%'then 'Z-A1'
			when ��ķ��з� like '%����������%'then 'Z-A1'  --�����Ͷƽ̨�������⴦��
			else (case when  Grade is NULL then 'Z-B5' 
						when	Grade='AAA+'	then	'Z-A1'
						when	Grade='AAA'	then	'Z-A2'
						when	Grade='AAA-'	then	'Z-A4'
						when	Grade='AA+'	then	'Z-A5'
						when	Grade='AA'	then	'Z-B2'
						when	Grade='AA-'	then	'Z-B4'
						when	Grade='A+'	then	'Z-C1'
						when	Grade='A'	then	'Z-C2'
						when	Grade='A-'	then	'Z-C3'
						else 'Z-D' end) end
			)as '������ȫ'
			,MK_Duration
	
		from [Position_DB].[RWA].[mRWA_All] where Balance_date=@BalanceDate
			and RWA��Ч��=1 
			and Underlying not in ('000300.SH','000016.SH','000905.SH')  --ָ��������IRC
			and SecuCategory in ('Bond','FwdBond','Equity','CVBond')
		group by ��Ĵ���,��ķ��з�,GRADE,MK_Duration
	)as b
	on a.��Ĵ���=b.��Ĵ���
		group by a.��Ĵ���, a.IRCType, b.��ķ��з�, b.������ȫ,MK_Duration

)as ab
where (��˾�ܼ�<>0 or ���ս���<>0 or ���ղƸ�����<>0 or ��������<>0
or �в�Ͷ�ʲ�<>0 or �ʽ���Ӫ��<>0 or Ȩ��Ͷ�ʲ�<>0 or Ȩ��Ӧ��<>0 or ��Ʊ����<>0 
or ����ҵ����<>0 or ��������<>0 or ����Ӧ��<>0 or ����Ͷ��ҵ����<>0 
or ֤��ȯ��<>0 or ֤���Ȩ������<>0 or ����<>0 )


)




GO