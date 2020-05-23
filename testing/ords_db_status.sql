set lines 200 pages 200 tab off

column username format A25
column account_status format A20

select con_id, username, account_status
  from cdb_users
 where username like 'ORDS%'
    or username like 'APEX%'
 order by username, con_id
;

exit
