# instrument_weblogic_cursor_leak

The attached script (spool_open_cursors.sql) would generate the following files and would append the CSV output to each file for every execution.
     
    $ ls -l *-talloc*txt
    -rwxr-xr-x 1 karl None  13214 Jul 12 17:16 gettemp-talloc2.txt<- temp space per SID
    -rwxr-xr-x 1 karl None  36149 Jul 12 17:16 gvsession-talloc2.txt<- load balancing per SID
    -rwxr-xr-x 1 karl None  28193 Jul 12 17:16 open_cursors_detail-talloc2.txt   <- the open cursors details of the top 1 SID
    -rwxr-xr-x 1 karl None 196056 Jul 12 17:16 open_cursors-talloc2.txt <- open cursors per SID
 
To deploy the monitoring script, copy/save the attache SQL file on the server with SQL*Plus installed. Preferably create a new folder and have all the scripts/files there.
 
Then run the following command, you can add & at the end to have it run in the background. Or just execute it from VNC.
The command calls the SQL file, and loops forever for every 20 seconds. You can put 60 or 120 seconds here, the output is not that big a few KB per execution.
 
The example below shows two iterations. But it builds that text file as a time series data we can mine later. So let’s leave it running for the whole day or few days.
     
    $ while : ; do sqlplus alloc_app_perf/<password>@<tns> @spool_open_cursors ; echo "----" ; sleep 20 ; done
     

    SQL*Plus: Release 11.1.0.6.0 - Production on Wed Jul 12 17:16:14 2017
     
    Copyright (c) 1982, 2007, Oracle.  All rights reserved.
     
     
    Connected to:
    Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production 
    With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
    Advanced Analytics and Real Application Testing options
     
    Disconnected from Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
    With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
    Advanced Analytics and Real Application Testing options
    ----
     
    SQL*Plus: Release 11.1.0.6.0 - Production on Wed Jul 12 17:16:30 2017
     
    Copyright (c) 1982, 2007, Oracle.  All rights reserved.
     
     
    Connected to:
    Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
    With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
    Advanced Analytics and Real Application Testing options
     
    Disconnected from Oracle Database 12c Enterprise Edition Release 12.1.0.1.0 - 64bit Production
    With the Partitioning, Real Application Clusters, Automatic Storage Management, OLAP,
    Advanced Analytics and Real Application Testing options
    ----
 
 
Then we can copy the text files once in a while and graph them. 
 
Let’s say there’s an ORA- error, we can detail on the specific SQL_ID that caused it and see how it grew overtime and the whole who, when, where details. Then we can grab the file open_cursors_detail-talloc2.txt (also time series) to detail on the exact SQL_TEXT that caused it.