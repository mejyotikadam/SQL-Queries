-- Get details from Sendmail Server
-- By: Jyoti Kadam
create table Dtsdetail
( Dtsname varchar(250), 
[To] varchar(250), 
CC varchar(250), 
BCC varchar(250), 
[Subject] varchar(250))  

CREATE TABLE [dbo].[SendmailFinalData](
	[name] [sysname] NOT NULL,
	[step_name] [sysname] NULL,
	[dts] [nvarchar](max) NULL,
	[Dtsname] [varchar](250) NULL,
	[To] [varchar](250) NULL,
	[CC] [varchar](250) NULL,
	[BCC] [varchar](250) NULL,
	[Subject] [varchar](250) NULL
) ON [PRIMARY]  



 Declare @Dtsname varchar(500), @Tasktype varchar(500);      


SELECT a.name,b.step_name,left(replace(b.command,'/File "',''),charindex('.dtsx',b.command)-3) dts into #jobs FROM msdb.dbo.sysjobs a left join (select * from msdb.dbo.sysjobsteps   
where command like '%.dtsx%') b on a.job_id=b.job_id where command is not null and a.enabled=1    

select * into #jobs1 from #jobs

 

while exists(select top 1* from #jobs) 
Begin       

 Select Top 1  @dtsname=dts from #jobs     


Declare @SQL Varchar(Max)  
Set @SQL=''  


Set @SQL=' 
select    cast(pkgblob.BulkColumn as XML) pkgXML  into ##temp from    openrowset(bulk '''+@dtsname+''',single_blob) as pkgblob '
Print @SQL  
Exec(@SQL) 


SELECT     Pkg.props.query('.').query('declare namespace DTS="www.microsoft.com/SqlServer/Dts";
./DTS:Executable[@DTS:ExecutableType=''Microsoft.SqlServer.Dts.Tasks.SendMailTask.SendMailTask, Microsoft.SqlServer.SendMailTask, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'']/DTS:ObjectData/*') Detail 
 into #temp2  
 FROM   ##temp  CROSS    
APPLY pkgXML.nodes('declare namespace DTS="www.microsoft.com/SqlServer/Dts";                           
 //DTS:Executable[@DTS:ExecutableType!=''STOCK:SEQUENCE''                        
 and    @DTS:ExecutableType!=''STOCK:FORLOOP''                        
and    @DTS:ExecutableType!=''STOCK:FOREACHLOOP''                  
      and not(contains(@DTS:ExecutableType,''.Package.''))]') Pkg(props)  



select cast(Detail as varchar(max)) as Detailtext into #temp3 from #temp2  

delete from #temp3 where isnull(ltrim(rtrim(Detailtext)),'')=''  

select detailtext,Replace(Substring(detailtext,charindex('SendMailTask:To="',detailtext)+17,charindex('SendMailTask:CC',detailtext)-charindex('SendMailTask:To="',detailtext)),'" SendMailTask:CC="','')[To], 
 Replace(Substring(detailtext,charindex('SendMailTask:CC="',detailtext)+17,charindex('SendMailTask:BCC',detailtext)-charindex('SendMailTask:CC="',detailtext)),'" SendMailTask:BCC=','')[CC],  
Replace(Substring(detailtext,charindex('SendMailTask:BCC="',detailtext)+18,charindex('SendMailTask:Subject',detailtext)-charindex('SendMailTask:BCC="',detailtext)),'" SendMailTask:Subje','')[BCC],  
Replace(Substring(detailtext,charindex('SendMailTask:Subject="',detailtext)+22,charindex('" SendMailTask:Priority',detailtext)-charindex('SendMailTask:Subject="',detailtext)),'" SendMailTask:Priorit','')[Subject] 
into #temp4  
from #temp3 

Insert into Dtsdetail  
select @Dtsname,[To],CC,BCC,[Subject] from #temp4  


drop table #temp4
drop table #temp3
drop table #temp2
drop table ##temp

delete from #jobs where dts=@Dtsname
 End  ;
  


Insert into SendmailFinalData 
select * from #jobs1 a left join Dtsdetail b on a.dts=b.Dtsname  

drop table #jobs1
drop table #jobs


select * from SendmailFinalData 