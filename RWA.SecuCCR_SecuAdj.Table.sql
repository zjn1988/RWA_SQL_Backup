USE [Position_DB]
GO
/****** Object:  Table [RWA].[SecuCCR_SecuAdj]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[SecuCCR_SecuAdj](
	[ID] [int] NOT NULL,
	[UpdateTime] [datetime] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[证券代码] [varchar](255) NULL,
	[代码] [varchar](255) NULL,
	[市场] [varchar](255) NULL,
	[证券名称] [varchar](255) NULL,
	[证券类型] [varchar](255) NULL,
	[上市日期] [date] NULL,
	[日均成交量] [decimal](28, 10) NULL,
	[收盘价] [decimal](28, 10) NULL,
	[定性折算比例] [decimal](28, 10) NULL,
	[最大折扣] [decimal](28, 10) NULL,
	[最小折扣] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_SecuAdj] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
