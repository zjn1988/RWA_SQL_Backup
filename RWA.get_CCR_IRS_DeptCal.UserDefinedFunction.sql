USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_CCR_IRS_DeptCal]    Script Date: 2016/2/24 11:16:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zfb,,Name>
-- Create date: <2015-10-19,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[get_CCR_IRS_DeptCal]
( 
	@BalanceDate DATETIME 

	)

RETURNS TABLE 
AS
RETURN 
(

select 		
结算日,账户范围,Acc1.*,总规模,净规模,合约价值合计,内评等级,PD,LGD,平均期限,期限调整
,([UL_PD（金融机构）]*LGD*期限调整*12.5) as 平均风险权重		
	
from		
(		
	select * from (SELECT ROW_NUMBER() OVER( ORDER BY 组合名称 ) AS 净额结算#,tmp1.* 	
	FROM(select distinct 部门# as 组合名称 from Position_DB.rwa.get_CCR_IRS(@balancedate)) as tmp1 )tmp2	
) as Acc1		
left join		
(		
	Select *, 平均期限*mAdjust1+mAdjust2 as 期限调整
	FROM
	(		
		select CONVERT(varchar(20), Balance_date, 111) as 结算日,DeptId as 账户范围,部门# as 识别码	
			,sum(abs(notional))as 总规模, sum(notional)as 净规模
			,sum(presentvalue_CNY)as 合约价值合计,'' as 风险敞口,内评等级,PD,LGD,[UL_PD（金融机构）]
			,avg(cast(datediff(day,balance_date,Settleday) as float)/365) as 平均期限
		from Position_DB.rwa.get_CCR_IRS(@balancedate)	
		group by DeptId,部门#,内评等级,pd,lgd,[UL_PD（金融机构）],Balance_date
	)as Acc3
	left join
	(
		select InnerRating,mAdjust1,mAdjust2
		from Position_DB.RWA.parameter_ULPDMatrix() 
	)as b
	on Acc3.内评等级=b.innerrating
) as Acc2		
on 组合名称=识别码		

)





GO
