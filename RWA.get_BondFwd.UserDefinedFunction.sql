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
-- Description:	<获得债券远期业务数据,用于RWA计算>
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
	CONVERT(varchar(10), a.balance_date , 111) as 结算日 ,
	a.ContractType as 业务类型,
	a.SecurityAccount as 账户,
	a.Account as 大账户,
	a.Department as 部门,
	a.PositionCode as 合约代码,
	a.Notional as 名义本金,
	a.value as 合约价值,
	a.FullCode as 标的债券代码,
	b.CurveName as 利率曲线,
	a.Counterparter as 交易对手,
	CONVERT(varchar(10),a.SettleDay , 111) as 合约到期日,
	c.B_COUPON as 收益率,
	c.B_COUPON_TYPE as  付息频率
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
	and a.Department <> '外部'
	and a.TradeType = '远期'
	and a.Notional<>0
	--and c.balance_date=@BalanceDate
)

--X_CNBD  China_InterBank
--XSHG    China_ShangHai
--XSHE    China_ShenZhen
--China_OTC







GO
