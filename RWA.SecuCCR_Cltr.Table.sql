USE [Position_DB]
GO
/****** Object:  Table [RWA].[SecuCCR_Cltr]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[SecuCCR_Cltr](
	[ID] [int] NOT NULL,
	[UpdateTime] [datetime] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[业务类型] [varchar](255) NULL,
	[净额结算识别码] [varchar](255) NULL,
	[证券代码] [varchar](255) NULL,
	[证券类型] [varchar](255) NULL,
	[证券市值] [decimal](28, 10) NULL,
	[上市日期] [date] NULL,
	[流动性期限] [decimal](28, 10) NULL,
	[定性扣减] [decimal](28, 10) NULL,
	[扣减上限] [decimal](28, 10) NULL,
	[扣减下限] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_Cltr] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
