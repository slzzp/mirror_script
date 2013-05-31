#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
CUT="/usr/bin/cut"
GREP="/bin/grep"
TR="/usr/bin/tr"
WC="/usr/bin/wc"


while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "$0" == "$1" ]; then
        shift
        continue
    fi

    URL=`echo -n "$1"`

    # check if $1's prefix is '//'
    CHECKSLASHSLASH=`echo "$1" | ${CUT} -c 1-2`
    if [ "//" = "${CHECKSLASHSLASH}" ]; then
        URL=`echo -n "http:$1"`
    fi

    # parse url
    HOSTNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$3);}'`
    HOSTNAMEA=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$1);}'`
    HOSTNAMEB=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$2);}'`
    HOSTNAMEC=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$3);}'`
    HOSTNAMED=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$4);}'`
    PATHA=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
    PATHB=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$5);}'`
    PATHC=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$6);}'`
    PATHD=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$7);}'`

    # check url    

    echo "error: unknown url: ${URL}"
    exit
done
