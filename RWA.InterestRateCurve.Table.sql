USE [Position_DB]
GO
/****** Object:  Table [RWA].[InterestRateCurve]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[InterestRateCurve](
	[ID] [int] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[CurveName] [varchar](255) NULL,
	[term] [int] NULL,
	[InterestRate] [decimal](20, 15) NULL,
 CONSTRAINT [PK_InterestRateCurve] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
