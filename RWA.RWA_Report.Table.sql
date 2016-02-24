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
	[��ϴ���] [varchar](255) NULL,
	[���] [varchar](255) NULL,
	[�ܹ�ģ] [decimal](28, 10) NULL,
	[����ģ] [decimal](28, 10) NULL,
	[SVaR] [decimal](28, 10) NULL,
	[IRC] [decimal](28, 10) NULL,
	[GeneralmRWA] [decimal](28, 10) NULL,
	[SpecificmRWA] [decimal](28, 10) NULL,
	[MktRWA] [decimal](28, 10) NULL,
	[CreditRWA] [decimal](28, 10) NULL,
	[StdRWA] [decimal](28, 10) NULL,
	[TotalRWA] [decimal](28, 10) NULL,
	[�۳������ʽ�ʹ�÷�����] [decimal](28, 10) NULL,
	[RoRWA] [decimal](28, 10) NULL,
	[VaR��Ч��] [decimal](28, 10) NULL,
	[IRC��Ч��] [decimal](28, 10) NULL,
	[CCR��Ч��] [decimal](28, 10) NULL,
	[�ο�PnL] [decimal](28, 10) NULL,
	[�ο�RoRWA] [decimal](28, 10) NULL,
 CONSTRAINT [PK_RWA_Report] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
