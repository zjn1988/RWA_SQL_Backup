USE [Position_DB]
GO
/****** Object:  Table [RWA].[mRWA_All]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[mRWA_All](
	[ID] [int] NOT NULL,
	[BALANCE_DATE] [date] NULL,
	[组合代码] [varchar](255) NULL,
	[AccId] [varchar](255) NULL,
	[SubAccId] [varchar](255) NULL,
	[SECUCATEGORY] [varchar](255) NULL,
	[SECUCODE] [varchar](255) NULL,
	[SECUMARKET] [varchar](255) NULL,
	[SettleDay] [date] NULL,
	[Pay_Freq] [varchar](255) NULL,
	[固定利率] [decimal](28, 12) NULL,
	[quantity] [decimal](28, 10) NULL,
	[ccy] [varchar](255) NULL,
	[PresentValue_CNY] [decimal](28, 10) NULL,
	[Notional] [decimal](28, 10) NULL,
	[DV01] [decimal](28, 10) NULL,
	[counterparter] [varchar](255) NULL,
	[CounterpartyName] [varchar](255) NULL,
	[内评等级] [varchar](255) NULL,
	[InnerRating] [varchar](255) NULL,
	[Underlying] [varchar](255) NULL,
	[UnderlyingMarket] [varchar](255) NULL,
	[标的代码] [varchar](255) NULL,
	[MK_Duration] [decimal](28, 10) NULL,
	[B_MTR_Date] [date] NULL,
	[标的发行方] [varchar](255) NULL,
	[GRADE] [varchar](255) NULL,
	[发行人内评等级] [varchar](255) NULL,
	[CurveName] [varchar](255) NULL,
	[dollordelta1%] [decimal](28, 10) NULL,
	[fundtype] [varchar](255) NULL,
	[InVaRLimit] [int] NULL,
	[inCompany] [int] NULL,
	[RWA有效性] [int] NULL,
 CONSTRAINT [PK_mRWA_All] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
