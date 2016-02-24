USE [Position_DB]
GO
/****** Object:  UserDefinedFunction [RWA].[parameter_ULPDMatrix]    Script Date: 2016/2/24 13:11:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<zjn,,Name>
-- Create date: <2015-10-12,,>
-- Description:	<获得市场风险数据,用于RWA计算>
-- =============================================
CREATE FUNCTION [RWA].[parameter_ULPDMatrix]()

RETURNS TABLE 
AS
RETURN 

(
select  InnerRating

/*内评违约概率*/
,(case InnerRating
when 'Z-A1' then 0.0003
when 'Z-A2' then 0.0010025
when 'Z-A3' then 0.00014675
when 'Z-A4' then 0.0018325
when 'Z-A5' then 0.00329
when 'Z-B1' then 0.0056525
when 'Z-B2' then 0.007869405
when 'Z-B3' then 0.010316905
when 'Z-B4' then 0.0133575
when 'Z-B5' then 0.0170175
when 'Z-C1' then 0.0233575
when 'Z-C2' then 0.03654
when 'Z-C3' then 0.055285
when 'Z-D' then 0.3798
when 'Z-CDF' then 0.847215
else '' end) as PD

/*个人UL违约概率*/
,(case InnerRating
when 'Z-A1' then 0.007913069
when 'Z-A2' then 0.019881527
when 'Z-A3' then 0.02615001
when 'Z-A4' then 0.030523124
when 'Z-A5' then 0.04484077
when 'Z-B1' then 0.061576125
when 'Z-B2' then 0.07296956
when 'Z-B3' then 0.082458846
when 'Z-B4' then 0.091189525
when 'Z-B5' then 0.098668868
when 'Z-C1' then 0.106806917
when 'Z-C2' then 0.114481057
when 'Z-C3' then 0.119281758
when 'Z-D' then 0.212225246
when 'Z-CDF' then 0.096158866
else '' end) as IndivULPD


/*公司UL违约概率*/
,(case InnerRating
when	'Z-A1'	then	0.013474202
when	'Z-A2'	then	0.033250275
when	'Z-A3'	then	0.043388014
when	'Z-A4'	then	0.050388407
when	'Z-A5'	then	0.072980529
when	'Z-B1'	then	0.099021375
when	'Z-B2'	then	0.116829477
when	'Z-B3'	then	0.132044416
when	'Z-B4'	then	0.146823991
when	'Z-B5'	then	0.160813737
when	'Z-C1'	then	0.179528165
when	'Z-C2'	then	0.208964728
when	'Z-C3'	then	0.243927002
when	'Z-D'	then	0.412646761
when	'Z-CDF'	then	0.140021419
else '' end) as CompULPD

/*金融机构UL违约概率*/
,(case InnerRating
when	'Z-A1'	then	0.018336737
when	'Z-A2'	then	0.04492545
when	'Z-A3'	then	0.058329129
when	'Z-A4'	then	0.067494171
when	'Z-A5'	then	0.096558259
when	'Z-B1'	then	0.129040392
when	'Z-B2'	then	0.150576901
when	'Z-B3'	then	0.168509328
when	'Z-B4'	then	0.185499396
when	'Z-B5'	then	0.201200658
when	'Z-C1'	then	0.221723464
when	'Z-C2'	then	0.253499587
when	'Z-C3'	then	0.291331651
when	'Z-D'	then	0.453239703
when	'Z-CDF'	then	0.144796719
else '' end) as BankULPD

/*期限调整系数1*/
,(case InnerRating
when	'Z-A1'	then	0.604115257
when	'Z-A2'	then	0.392044353
when	'Z-A3'	then	0.343183963
when	'Z-A4'	then	0.317605355
when	'Z-A5'	then	0.258755988
when	'Z-B1'	then	0.213444229
when	'Z-B2'	then	0.189289369
when	'Z-B3'	then	0.171257553
when	'Z-B4'	then	0.155375805
when	'Z-B5'	then	0.141557477
when	'Z-C1'	then	0.124921568
when	'Z-C2'	then	0.103917323
when	'Z-C3'	then	0.086815433
when	'Z-D'	then	0.030793332
when	'Z-CDF'	then	0.016690491
else '' end) as mAdjust1

/*期限调整系数2*/
,(case InnerRating
when	'Z-A1'	then	0.395884743
when	'Z-A2'	then	0.607955647
when	'Z-A3'	then	0.656816037
when	'Z-A4'	then	0.682394645
when	'Z-A5'	then	0.741244012
when	'Z-B1'	then	0.786555771
when	'Z-B2'	then	0.810710631
when	'Z-B3'	then	0.828742447
when	'Z-B4'	then	0.844624195
when	'Z-B5'	then	0.858442523
when	'Z-C1'	then	0.875078432
when	'Z-C2'	then	0.896082677
when	'Z-C3'	then	0.913184567
when	'Z-D'	then	0.969206668
when	'Z-CDF'	then	0.983309509
else '' end) as mAdjust2

from (
select InnerRating
from [CreditRisk].[Counterparty].[CounterpartyBasicInfo]
where InnerRating <> ''
and len(InnerRating) <> 1
group by InnerRating
) as ULPD

)
GO
