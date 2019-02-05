rem Adjustments to Oracle XE

-- Option - Change Default to Unlimited --
alter profile default limit password_life_time unlimited;

alter user apex_public_user identified by APEX3PUB2user;
alter user apex_rest_public_user identified by APEX2rstPub4user;
alter user apex_listener identified by password;
alter user ords_public_user identified by password;

alter user apex_public_user account unlock;

-- EPG disable
exec dbms_xdb.sethttpport(0);

-- Add default Internal User

-- Add Workspaces

-- Adjust password complexity rules to be simple


rem Be sure to leave
exit

