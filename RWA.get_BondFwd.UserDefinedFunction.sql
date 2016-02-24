USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[get_BondFwd]    Script Date: 2016/2/24 11:15:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-04-22,,>
-- Description:	<���ծȯԶ��ҵ������,����RWA����>
-- =============================================
CREATE FUNCTION [RWA].[get_BondFwd]
( 
	@BalanceDate DATETIME 
	)

RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
	CONVERT(varchar(10), a.balance_date , 111) as ������ ,
	a.ContractType as ҵ������,
	a.SecurityAccount as �˻�,
	a.Account as ���˻�,
	a.Department as ����,
	a.PositionCode as ��Լ����,
	a.Notional as ���屾��,
	a.value as ��Լ��ֵ,
	a.FullCode as ���ծȯ����,
	b.CurveName as ��������,
	a.Counterparter as ���׶���,
	CONVERT(varchar(10),a.SettleDay , 111) as ��Լ������,
	c.B_COUPON as ������,
	c.B_COUPON_TYPE as  ��ϢƵ��
	from Position_DB.xir.acc_balance_zq2 as a left join
	(select CurveType,CurveName,SecuCode,
	case SecuMarket
	when 'China_InterBank' then 'X_CNBD'
	when 'China_ShangHai' then 'XSHG'
	when 'China_ShenZhen' then 'XSHE'
	else SecuMarket
	end as SecuMarket,
	SecuCategory from Position_DB.mkt.BondCurveMapping 
	where balance_date=@BalanceDate
	)as b on a.Code=b.SecuCode and a.MarketType=b.SecuMarket
	left join position_db.mkt.xir_vbond  as c
	on a.Code=c.I_CODE and a.MarketType=c.M_Type
	where a.balance_date = @BalanceDate
	and a.Department <> '�ⲿ'
	and a.TradeType = 'Զ��'
	and a.Notional<>0
	--and c.balance_date=@BalanceDate
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC







GO
