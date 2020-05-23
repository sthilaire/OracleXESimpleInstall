-- Adjustments to Oracle XE

-- prompt '... remove default PDB...'
-- alter pluggable database xepdb1 close immediate;
-- drop pluggable database xepdb1 including datafiles;

-- prompt '... set default datafile destination...'
-- alter system set db_create_file_dest='/opt/oracle/oradata';

-- prompt '... create pdb with OMF...'
-- CREATE PLUGGABLE DATABASE xepdb1
--     ADMIN USER pdbadmin IDENTIFIED BY password
--     DEFAULT TABLESPACE users;


-- Option - Change Default to Unlimited --
alter profile default limit password_life_time unlimited;

alter user ords_public_user identified by password;
alter user ords_public_user account unlock;

-- EPG disable
exec dbms_xdb.sethttpport(0);

-- Adjust password complexity rules to be simple

-- Be sure to leave
exit
