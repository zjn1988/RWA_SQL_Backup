USE [Position_DB]
GO
/****** Object:  Table [RWA].[SecuCCR_Netting_2]    Script Date: 2016/2/24 16:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RWA].[SecuCCR_Netting_2](
	[ID] [int] NOT NULL,
	[UpdateTime] [datetime] NOT NULL,
	[Balance_Date] [date] NOT NULL,
	[����������] [varchar](255) NULL,
	[ҵ������] [varchar](255) NULL,
	[����] [varchar](255) NULL,
	[�ͻ�] [varchar](255) NULL,
	[���屾��] [decimal](28, 10) NULL,
	[�ܸ�ծ] [decimal](28, 10) NULL,
	[���ʲ�] [decimal](28, 10) NULL,
	[ά�ֵ�������] [decimal](28, 10) NULL,
	[ʣ������] [decimal](28, 10) NULL,
	[���Կۼ�] [decimal](28, 10) NULL,
	[�����ۼ�] [decimal](28, 10) NULL,
	[�ۼ�����] [decimal](28, 10) NULL,
	[�ۼ�����] [decimal](28, 10) NULL,
	[���ռ�ֵ�ۼ�] [decimal](28, 10) NULL,
	[RWA�ȼ�������] [decimal](28, 10) NULL,
	[RWA������ʲ�] [decimal](28, 10) NULL,
	[�����ά�ֵ�������] [decimal](28, 10) NULL,
	[�����ճ���] [decimal](28, 10) NULL,
	[���������ȼ�] [varchar](255) NULL,
	[��������] [varchar](255) NULL,
	[PD] [decimal](28, 10) NULL,
	[ULPD] [decimal](28, 10) NULL,
	[LGD] [decimal](28, 10) NULL,
	[���޵���] [decimal](28, 18) NULL,
	[Ԥ����ʧ] [decimal](28, 10) NULL,
	[��Ԥ����ʧ] [decimal](28, 10) NULL,
	[�����ڷ���Ȩ��] [decimal](38, 25) NULL,
	[RWA] [decimal](28, 10) NULL,
	[���ճ���ռ��] [decimal](28, 10) NULL,
	[Ԥ����ʧռ��] [decimal](28, 10) NULL,
	[��Ԥ����ʧռ��] [decimal](28, 10) NULL,
	[RWAռ��] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_Netting_2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
