USE [Position_DB]
GO
/****** Object:  Table [RWA].[RWA_Report]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[RWA_Report](
	[ID] [int] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[组合代码] [varchar](255) NULL,
	[组合] [varchar](255) NULL,
	[总规模] [decimal](28, 10) NULL,
	[净规模] [decimal](28, 10) NULL,
	[SVaR] [decimal](28, 10) NULL,
	[IRC] [decimal](28, 10) NULL,
	[GeneralmRWA] [decimal](28, 10) NULL,
	[SpecificmRWA] [decimal](28, 10) NULL,
	[MktRWA] [decimal](28, 10) NULL,
	[CreditRWA] [decimal](28, 10) NULL,
	[StdRWA] [decimal](28, 10) NULL,
	[TotalRWA] [decimal](28, 10) NULL,
	[扣除其他资金使用费收益] [decimal](28, 10) NULL,
	[RoRWA] [decimal](28, 10) NULL,
	[VaR有效性] [decimal](28, 10) NULL,
	[IRC有效性] [decimal](28, 10) NULL,
	[CCR有效性] [decimal](28, 10) NULL,
	[参考PnL] [decimal](28, 10) NULL,
	[参考RoRWA] [decimal](28, 10) NULL,
 CONSTRAINT [PK_RWA_Report] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
