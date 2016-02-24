USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_VarPositionDtl_BondCurve]    Script Date: 2016/2/24 13:11:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<���Լ������ҵ������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_VarPositionDtl_BondCurve]
(	@StartDate DATETIME,
	@EndDate DATETIME, 
	@BalanceDate DATETIME
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select [CurveName], term, min(price) price, dailyDate
	FROM
	(
		select 
			case when A.[CurveName] ='CNY IRS - 3M Shibor' then '���ʻ���-Shibor_3M' 
			when A.[OldCurveName]= '��ծ�ط�����ծ����������(AAA)' then '��ծ�ط�����ծ����������(AAA)'
			when A.[OldCurveName]= '��ծ����ծ����������(��˰)'  then '��ծ����ծ����������(��˰)' 
			when A.[OldCurveName]= '��ծ����ծ����������'  then '��ծ����ծ����������'
			when A.[OldCurveName]=  '��ծ��ծ����������(ԭ���м�̶����ʹ�ծ����������)' then '��ծ��ծ����������(ԭ���м�̶����ʹ�ծ����������)'
			else A.[CurveName] end [CurveName]
	--		case A.[CurveName] 
	--			when 'CNY IRS - 3M Shibor' then '���ʻ���-Shibor_3M' 
	--			else A.[CurveName]
	--		end [CurveName]
			,B.term
			,B.price
			,B.dailyDate from 
			(SELECT 
				distinct(case ([CurveName]) 
					when  '���ʻ���-Shibor_3M' then 'CNY IRS - 3M Shibor'
					when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
					when 'FR007' then 'CNY IRS - 7D repo'
					when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'

					when  '��ծ�ط�����ծ����������(AAA)' then  '�ط�����ծ����������'
					when  '��ծ����ծ����������(��˰)'    then  '�̶���������������������(��˰)'
					when  '��ծ����ծ����������'          then '�̶���������������������'
					when  '��ծ��ծ����������(ԭ���м�̶����ʹ�ծ����������)' then '���м�̶����ʹ�ծ����������'
					ELSE [CurveName]
				end
				) [CurveName],
				[CurveName] as [OldCurveName]
				FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
				where [Balance_Date] =@BalanceDate 
				and (lower(SVaRType) = 'bond' or lower(SVaRType)  = 'bondfuture')
				--and [CurveName]<>'���ʻ���-Shibor_3M'
			) as A
			inner join
			(select 
				--curveNameCn
				localCode
				,LEFT(curveVertexName,LEN(curveVertexName)-1)*
				(case right(curveVertexName,1)
				when 'D' THEN 1
				WHEN 'W' THEN 7
				WHEN 'M' THEN 30
				WHEN 'Y' THEN 365
				END
				) as term
				,price
				, CONVERT(varchar(10), dailyDate, 111) dailyDate
				--from zx_audit.zx_mkt.v_getBondYield v
				from zx_audit.zx_mkt.v_getMktDataInfo v
				where dataSetId = 22
				and v.dailydate between @StartDate and @EndDate
			) as B
			--ON A.[CurveName]=LEFT(B.curveNameCn,LEN(B.curveNameCn)-3)
			ON A.[CurveName]=LEFT(B.localCode,LEN(B.localCode)-3)
		--���ݿ�洢----------------------------------------------------------------
		UNION ALL
		select 

			case A.[CurveName]
				when 'CNY IRS - 3M Shibor' then '���ʻ���-Shibor_3M' 
				else A.[CurveName]
			end [CurveName]
			,B.term
			,B.price
			,B.dailyDate from 
			(SELECT 
				distinct(case ([CurveName]) 
					when  '���ʻ���-Shibor_3M' then 'CNY IRS - 3M Shibor'
					when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
					when 'FR007' then 'CNY IRS - 7D repo'
					when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'
					ELSE [CurveName]
				end
				) [CurveName]
	
				FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
				where [Balance_Date] =@BalanceDate 
				and (lower(SVaRType) = 'bond' or lower(SVaRType)  = 'bondfuture')
				--and [CurveName]<>'���ʻ���-Shibor_3M'
			) as A
			inner join
			(select 
				CurveName curveNameCn
				,term
				,InterestRate price
				, CONVERT(varchar(10), Balance_Date, 111) dailyDate
				--from zx_audit.zx_mkt.v_getBondYield v
				from [Position_DB].[RWA].BondIrsCurve v
				where  v.Balance_Date between @StartDate and @EndDate
			) as B
			ON A.[CurveName]=B.curveNameCn
	---------------------------------------------------------------------------
	) AS Z 
	GROUP BY Z.[CurveName], Z.term, Z.dailyDate
	UNION ALL
		select 		
			case A.[CurveName]
			when 'CNY IRS - 3M Shibor' then '���ʻ���-Shibor_3M' 
			else A.[CurveName]
		end [CurveName]
		,B.term,B.price,B.dailyDate from 
		(SELECT 
			distinct(case ([CurveName]) 
				when  '���ʻ���-Shibor_3M' then 'CNY IRS - 3M Shibor'
				when 'DEPO_F01Y' then 'CNY IRS - 1Y Deposit'
				when 'FR007' then 'CNY IRS - 7D repo'
				when 'SHIBOR-3M' then 'CNY IRS - 3M Shibor'
				ELSE [CurveName]
			end) [CurveName]
			FROM [Position_DB].[RWA].[VarPositionDtlAdj_v2] 
			where [Balance_Date] =@BalanceDate 
			and (lower(SVaRType) = 'bond' or lower(SVaRType)  = 'bondfuture' )
			and [CurveName]='���ʻ���-Shibor_3M'
		) as A
		inner join
		(select 
			 [CurveName] 	curveNameCn
			,[term] term
			,[InterestRate] price
			, CONVERT(varchar(10), [Balance_Date], 111) dailyDate
			from [Position_DB].[RWA].[InterestRateCurve]
			where [Balance_Date] between @StartDate and @EndDate
		) as B
		ON A.[CurveName]=B.curveNameCn
	--and c.balance_date=@BalanceDate
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC



--�ж��������Ʊ��

--select 
--	distinct(curveNameCn),localCode-- ,distinct(curveVertexName)--, MIN( CONVERT(varchar(10), dailyDate, 111)) BEGINDATE,MAX(dailyDate)
--	from zx_audit.zx_mkt.v_getMktDataInfo v
--	where dataSetId = 22
--	and curveNameCn<>localCode
--	--and v.dailydate= '2010-01-04' 
--	GROUP BY localCode,curveNameCn
--	ORDER BY localCode



GO
