USE [Position_DB]
GO
/****** Object:  Table [RWA].[SecuCCR_SecuInfo]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[SecuCCR_SecuInfo](
	[ID] [int] NOT NULL,
	[UpdateTime] [datetime] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[֤ȯ����] [varchar](255) NULL,
	[����] [varchar](255) NULL,
	[�г�] [varchar](255) NULL,
	[֤ȯ����] [varchar](255) NULL,
	[֤ȯ����] [varchar](255) NULL,
	[����Ͷ������] [varchar](255) NULL,
	[��������] [date] NULL,
	[�վ��ɽ���] [decimal](28, 10) NULL,
	[��ͨA��] [decimal](28, 10) NULL,
	[���̼�] [decimal](28, 10) NULL,
	[���������] [date] NULL,
	[�о���] [decimal](28, 10) NULL,
	[������ҵ] [varchar](255) NULL,
	[����ծ������] [varchar](255) NULL,
	[ROE1] [decimal](28, 10) NULL,
	[ROE2] [decimal](28, 10) NULL,
	[�ֹ���������] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_SecuInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
