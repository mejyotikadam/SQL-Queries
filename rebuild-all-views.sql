-----------------------------------------------------------------------------
-- REFRESH ALL VIEWS 
-- By: Jyoti Kadam
-----------------------------------------------------------------------------
SET NOCOUNT ON
DECLARE @SQL varchar(max) = ''
SELECT @SQL = @SQL + 'print ''Refreshing --> ' + name + '''
EXEC sp_refreshview ' + name + ';
'
  FROM sysobjects 
  WHERE type = 'V' and name like 'vw_%'  --< condition to select all views, may vary by your standards
--SELECT @SQL
EXEC(@SQL)
go
