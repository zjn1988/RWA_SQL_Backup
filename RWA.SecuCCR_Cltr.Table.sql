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
	[ҵ������] [varchar](255) NULL,
	[�������ʶ����] [varchar](255) NULL,
	[֤ȯ����] [varchar](255) NULL,
	[֤ȯ����] [varchar](255) NULL,
	[֤ȯ��ֵ] [decimal](28, 10) NULL,
	[��������] [date] NULL,
	[����������] [decimal](28, 10) NULL,
	[���Կۼ�] [decimal](28, 10) NULL,
	[�ۼ�����] [decimal](28, 10) NULL,
	[�ۼ�����] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_Cltr] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
