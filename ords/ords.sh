#!/bin/sh
#
# https://warp11.nl/2012/02/apex-listener-startupshutdown-script/
# http://krisrice.io/2010-12-10-listener-startupshutdown-script/
#
. /etc/rc.d/init.d/functions
NAME="Oracle Application Express Listener"
JAVA="/my/install/path/to/jdk/jre/bin/java"
APEXWAR="/my/install/path/to/apex_listener/apex.war"


OPTIONS="-Xmx1024m -Xms256m  -jar $APEXWAR"

LOGFILE=/tmp/apex_listener.log
PIDFILE=/tmp/apex_listener.pid
start() {
        echo -n "Starting $NAME: "
        if [ -f $PIDFILE ]; then
                PID=`cat $PIDFILE`
                echo APEX Listener already running: $PID
                exit 2;
        else
                nohup $JAVA $OPTIONS 2>&1 > $LOGFILE  &
                RETVAL=$!
                echo Started PID: $RETVAL
                echo
                echo $RETVAL >>$PIDFILE
                return $RETVAL
        fi

}

status() {
        echo -n "Status $NAME: "
        if [ -f $PIDFILE ]; then
                PID=`cat $PIDFILE`
                echo APEX Listener already running: $PID
                ps -ef | grep $PID
        else
                echo APEX Listener not running
        fi
}

stop() {
        if [ -f $PIDFILE ]; then
                PID=`cat $PIDFILE`
                echo -n "Shutting down $NAME "
                echo
                kill $PID
                rm -f $PIDFILE
        else
                echo APEX Listener not running
        fi
        return 0
}

log() {
        tail -f $LOGFILE
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    log)
        log
        ;;
    *)
        echo "Usage:  {start|stop|status|restart|log}"
        exit 1
        ;;
esac
exit $?
