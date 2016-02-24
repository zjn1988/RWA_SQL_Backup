USE [Position_DB]
GO
/****** Object:  Table [RWA].[VarPositionDtl_v2]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[VarPositionDtl_v2](
	[ID] [int] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[SVaRType] [varchar](255) NULL,
	[RiskFactor] [varchar](255) NULL,
	[到期天数] [int] NULL,
	[CurveName] [varchar](255) NULL,
	[ValuationFactor] [decimal](28, 10) NULL,
	[组合] [varchar](255) NULL,
 CONSTRAINT [PK_VarPositionDtl_v2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
