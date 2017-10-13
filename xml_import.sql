---Cross-tab Report with XML Import
-- By: Jyoti Kadam
CREATE procedure [dbo].[sp_Get_Statistics]
(
    @filename nvarchar(100)
)
AS

DECLARE @sql NVARCHAR(4000) = ' with SourcePackage as
(       SELECT    CAST(pkgblob.BulkColumn AS XML) pkgXML
        FROM    OPENROWSET(bulk ''' + @filename + ''', single_blob) AS pkgblob
		)
SELECT   
	Props.Prop.value(''../../../../../../MASTER_VALUE[1]'',''nvarchar(100)'') [Segment]
	, Props.Prop.value(''../../HEADING_1[1]'',''nvarchar(100)'') [Statistic]
	, Props.Prop.value(''SUM_AMOUNT[1]'', ''decimal(18,5)'')  [Value]

FROM 	
	SourcePackage t 
CROSS APPLY 
	pkgXML.nodes(''.//G_AMOUNT'') Props(Prop)
where
	Props.Prop.value(''SUM_AMOUNT[1]'', ''decimal(18,5)'') <> 0.00000
	and Props.Prop.value(''../../../../../../MASTER_VALUE[1]'',''nvarchar(100)'') <> ''Grand Total''
 ';

EXEC(@sql);


GO