

set feedback off pages 50000 term off head on und off trimspool on echo off lines 4000 colsep ',' arraysize 5000 verify off
col username format a30
COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;


-- sesstat open cursors count by SID, SQL_ID
spool open_cursors-&_instname..txt append
    select 
           TO_CHAR(sysdate, 'MM/DD/YY HH24:MI:SS') TM,
           c.inst_id,
           c.username,
           a.sid, c.machine, c.sql_id, c.prev_sql_id, c.plsql_object_id,
           sum(a.value) opened_cursors_current
    from   gv$sesstat a, gv$statname b, gv$session c
    where  a.statistic# = b.statistic#
    and    b.name = 'opened cursors current'
    and    c.sid = a.sid
    and    a.inst_id = c.inst_id
    group  by c.inst_id, c.username, a.sid, c.machine, c.sql_id, c.prev_sql_id, c.plsql_object_id
    order by  sum(a.value) asc;
spool off    
    
   
-- detail on specific SQLs
spool open_cursors_detail-&_instname..txt append
select TO_CHAR(sysdate, 'MM/DD/YY HH24:MI:SS') TM, inst_id, SQL_ID, hash_value, sid, user_name, sql_text
from gv$open_cursor
where sid in (
    select sid
    from (
        select c.inst_id, 
               c.username,
               a.sid, c.machine, c.sql_id, c.prev_sql_id, c.plsql_object_id,
               sum(a.value) "opened cursors current"
        from   gv$sesstat a, gv$statname b, gv$session c
        where  a.statistic# = b.statistic#
        and    b.name = 'opened cursors current'
        and    c.sid = a.sid
        and    a.inst_id = c.inst_id
        group  by c.inst_id, c.username, a.sid, c.machine, c.sql_id, c.prev_sql_id, c.plsql_object_id
        order by  sum(a.value) desc
        )
    where rownum < 2
)
order by sql_text asc;
spool off


-- sessions and taf 
spool gvsession-&_instname..txt append
select TO_CHAR(sysdate, 'MM/DD/YY HH24:MI:SS') TM, inst_id, count(*) count, username, machine,  failover_type ftype, failover_method fmethod, failed_over fo
from gv$session 
group by inst_id, username, machine, failover_type, failover_method, failed_over 
order by 2,4,3,5 asc;
spool off


-- sessions get temp space 
spool gettemp-&_instname..txt append
BREAK ON REPORT
COMPUTE SUM OF SPACE_MB ON REPORT
select  TO_CHAR(sysdate, 'MM/DD/YY HH24:MI:SS') TM
        ,se.inst_id
        ,se.username
        ,se.sid
        ,se.serial#
        ,su.extents
        ,su.blocks * to_number(rtrim(p.value))/1024/1024 as SPACE_MB
        ,se.sql_id
        ,tablespace
        ,segtype
        ,se.osuser osuser
from     gv$sort_usage su
        ,gv$parameter  p
        ,gv$session    se
where    p.name          = 'db_block_size'
and      su.session_addr = se.saddr
and      su.inst_id = se.inst_id
order by se.username, se.sid;


exit
    
