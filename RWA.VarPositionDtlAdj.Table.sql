USE [Position_DB]
GO
/****** Object:  Table [RWA].[VarPositionDtlAdj]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[VarPositionDtlAdj](
	[ID] [int] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[SVaRType] [varchar](255) NULL,
	[RiskFactor] [varchar](255) NULL,
	[到期天数] [int] NULL,
	[CurveName] [varchar](255) NULL,
	[公司总计] [decimal](28, 10) NULL,
	[固定收益部] [decimal](28, 10) NULL,
	[固收交易] [decimal](28, 10) NULL,
	[固收财富管理] [decimal](28, 10) NULL,
	[固收销售] [decimal](28, 10) NULL,
	[夹层投资部] [decimal](28, 10) NULL,
	[资金运营部] [decimal](28, 10) NULL,
	[权益投资部] [decimal](28, 10) NULL,
	[股衍业务线] [decimal](28, 10) NULL,
	[另类量化] [decimal](28, 10) NULL,
	[证金业务线] [decimal](28, 10) NULL,
	[证金券池] [decimal](28, 10) NULL,
	[证金股权及其他] [decimal](28, 10) NULL,
	[其他] [decimal](28, 10) NULL,
 CONSTRAINT [PK_VarPositionDtlAdj] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
