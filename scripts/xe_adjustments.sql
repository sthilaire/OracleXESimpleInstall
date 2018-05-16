rem Adjustments to Oracle XE

-- Option - Change Default to Unlimited --
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

alter user apex_public_user identified by password;

alter user apex_rest_public_user identified by password;


@apex_rest_config_core.sql oracle oracle

rem Be sure to leave
exit

