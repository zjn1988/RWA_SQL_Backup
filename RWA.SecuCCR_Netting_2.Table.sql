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
	[净额结算组合] [varchar](255) NULL,
	[业务类型] [varchar](255) NULL,
	[部门] [varchar](255) NULL,
	[客户] [varchar](255) NULL,
	[名义本金] [decimal](28, 10) NULL,
	[总负债] [decimal](28, 10) NULL,
	[总资产] [decimal](28, 10) NULL,
	[维持担保比例] [decimal](28, 10) NULL,
	[剩余期限] [decimal](28, 10) NULL,
	[定性扣减] [decimal](28, 10) NULL,
	[定量扣减] [decimal](28, 10) NULL,
	[扣减上限] [decimal](28, 10) NULL,
	[扣减下限] [decimal](28, 10) NULL,
	[风险价值扣减] [decimal](28, 10) NULL,
	[RWA等价折算率] [decimal](28, 10) NULL,
	[RWA折算后资产] [decimal](28, 10) NULL,
	[折算后维持担保比例] [decimal](28, 10) NULL,
	[净风险敞口] [decimal](28, 10) NULL,
	[主体内评等级] [varchar](255) NULL,
	[主体类型] [varchar](255) NULL,
	[PD] [decimal](28, 10) NULL,
	[ULPD] [decimal](28, 10) NULL,
	[LGD] [decimal](28, 10) NULL,
	[期限调整] [decimal](28, 18) NULL,
	[预期损失] [decimal](28, 10) NULL,
	[非预期损失] [decimal](28, 10) NULL,
	[净敞口风险权重] [decimal](38, 25) NULL,
	[RWA] [decimal](28, 10) NULL,
	[风险敞口占比] [decimal](28, 10) NULL,
	[预期损失占比] [decimal](28, 10) NULL,
	[非预期损失占比] [decimal](28, 10) NULL,
	[RWA占比] [decimal](28, 10) NULL,
 CONSTRAINT [PK_SecuCCR_Netting_2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
