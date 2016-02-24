USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRS_CompCal]    Script Date: 2016/2/24 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-19,,>
-- Description:	<����г���������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS_CompCal]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select 		
������,�˻���Χ,Acc1.*,�ܹ�ģ,����ģ,��Լ��ֵ�ϼ�,�����ȼ�,PD,LGD,ƽ������,���޵���
,([UL_PD�����ڻ�����]*LGD*���޵���*12.5) as ƽ������Ȩ��	
	
from		
(		
	select * from (SELECT ROW_NUMBER() OVER( ORDER BY ������� ) AS �������#,tmp1.* 	
	FROM(select distinct CounterpartyName as ������� from Position_DB.rwa.get_CCR_IRS(@balancedate)) as tmp1 )tmp2	
) as Acc1		
left join		
(		
	Select *, ƽ������*mAdjust1+mAdjust2 as ���޵���
	FROM
	(	
		select CONVERT(varchar(20), Balance_date, 111) as ������,'��˾' as �˻���Χ,CounterpartyName as ʶ����	
			,sum(abs(notional))as �ܹ�ģ, sum(notional)as ����ģ
			,sum(presentvalue_CNY)as ��Լ��ֵ�ϼ�,'' as ���ճ���,�����ȼ�,PD,LGD,[UL_PD�����ڻ�����]
			,avg(CAST(datediff(YEAR,balance_date,Settleday) AS FLOAT)) as ƽ������
		from Position_DB.rwa.get_CCR_IRS(@balancedate)	
		group by CounterpartyName,�����ȼ�,pd,lgd,[UL_PD�����ڻ�����],Balance_date
	)as Acc3
	left join
	(
		select InnerRating,mAdjust1,mAdjust2
		from Position_DB.RWA.parameter_ULPDMatrix() 
	)as b
	on Acc3.�����ȼ�=b.innerrating

) as Acc2		
on �������=ʶ����		

)





GO