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
	[��������] [int] NULL,
	[CurveName] [varchar](255) NULL,
	[��˾�ܼ�] [decimal](28, 10) NULL,
	[�̶����沿] [decimal](28, 10) NULL,
	[���ս���] [decimal](28, 10) NULL,
	[���ղƸ�����] [decimal](28, 10) NULL,
	[��������] [decimal](28, 10) NULL,
	[�в�Ͷ�ʲ�] [decimal](28, 10) NULL,
	[�ʽ���Ӫ��] [decimal](28, 10) NULL,
	[Ȩ��Ͷ�ʲ�] [decimal](28, 10) NULL,
	[����ҵ����] [decimal](28, 10) NULL,
	[��������] [decimal](28, 10) NULL,
	[֤��ҵ����] [decimal](28, 10) NULL,
	[֤��ȯ��] [decimal](28, 10) NULL,
	[֤���Ȩ������] [decimal](28, 10) NULL,
	[����] [decimal](28, 10) NULL,
 CONSTRAINT [PK_VarPositionDtlAdj] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
