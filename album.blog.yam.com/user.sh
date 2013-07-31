#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
CAT="/bin/cat"
CUT="/usr/bin/cut"
EXPR="/usr/bin/expr"
GREP="/bin/grep"
HEAD="/usr/bin/head"
MKDIR="/bin/mkdir"
RM="/bin/rm"
SED="/bin/sed"
TR="/usr/bin/tr"
WC="/usr/bin/wc"
WGET="/usr/bin/wget"


# -nv: basic option for simple message
# -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
# --no-check-certificate: do not check ssl/cert for https:// url
WGETOPTION="-nv -4 --no-check-certificate"
WGETREFERER=""


while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "$0" = "$1" ]; then
        shift
        continue
    fi

    # img's referer is url
    WGETREFERER="$1"

    URL=`echo -n "$1"`

    # check if $1's prefix is '//'
    CHECKSLASHSLASH=`echo "$1" | ${CUT} -c 1-2`
    if [ "//" = "${CHECKSLASHSLASH}" ]; then
        URL=`echo -n "http:$1"`
    fi

    # parse url
    # http://album.blog.yam.com/death1121
    HOSTNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$3);}'`
    PATHARGS=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
    PATHFILE=`echo "${PATHARGS}" | ${AWK} -F\? '{printf("%s",$1);}'`
    ARGS=`echo "${PATHARGS}" | ${AWK} -F\? '{printf("%s",$2);}'`

    USERNAME="${PATHFILE}"

    echo "check: username: [${USERNAME}]"

    if [ -z "${USERNAME}" -o ! -z "${ARGS}" ]; then
        echo "wrong url: ${URL}"
        exit
    fi

    FILENAME="user_$$.html"


    cd ~/tmp/

    # build dir
    ${MKDIR} -p album.blog.yam.com/${USERNAME}

    cd album.blog.yam.com/${USERNAME}


    # remove old html file first
    if [ -f "${FILENAME}" ]; then
        ${RM} -f ${FILENAME}
    fi

    # remove tmp file
    if [ -f "_${FILENAME}" ]; then
        ${RM} -f _${FILENAME}
    fi


    # get html file
    ${WGET} ${WGETOPTION} --referer="${WGETREFERER}" -O ${FILENAME} "${URL}"

    # pre-process html content
    ${CAT} ${FILENAME} | \
      ${SED} 's/&nbsp;//g' | \
      ${SED} 's/&gt;//g' | \
      ${SED} 's/&lt;//g' | \
      ${SED} 's/></>\n</g' \
      > _${FILENAME}

    if [ ! -s "_${FILENAME}" ]; then
        echo "process html error, url: ${URL}"
        ${RM} -f ${FILENAME} _${FILENAME}
        exit
    fi


    # process pager
    TMPLINE=`${CAT} _${FILENAME} | ${GREP} '最後一頁' | ${HEAD} -n 1`
    PAGEMAX=""
    PAGELIMIT=""

    if [ -n "${TMPLINE}" ]; then
        for ARGNAMEVALUE in `echo "${TMPLINE}" | ${TR} '&"' '  '`; do
            ARGNAME=`echo "${ARGNAMEVALUE}" | ${AWK} -F= '{printf("%s",$1);}'`
            ARGVALUE=`echo "${ARGNAMEVALUE}" | ${AWK} -F= '{printf("%s",$2);}'`
            # echo "arg name/value: ${ARGNAME} ${ARGVALUE}"

            if [ "page" = "${ARGNAME}" ]; then
                PAGEMAX="${ARGVALUE}"
            fi

            if [ "limit" = "${ARGNAME}" ]; then
                PAGELIMIT="${ARGVALUE}"
            fi
        done
    fi

    if [ ! -z "${PAGEMAX}" ]; then
        # user album has many pages
        COUNTER=1
        while [ ${COUNTER} -le ${PAGEMAX} ]; do
            PAGEURL="http://album.blog.yam.com/album.php?userid=${USERNAME}&page=${COUNTER}"
#            echo "${PAGEURL}"

            ~/work/mirror_script/album.blog.yam.com/album.sh "${PAGEURL}"

            COUNTER=`${EXPR} ${COUNTER} + 1`
        done
    else
        # user album has only 1 page
        PAGEURL="http://album.blog.yam.com/album.php?userid=${USERNAME}&page=1"
#        echo "${PAGEURL}"

        ~/work/mirror_script/album.blog.yam.com/album.sh "${PAGEURL}"
    fi


    # remove old html file first
    if [ -f "${FILENAME}" ]; then
        ${RM} -f ${FILENAME}
    fi

    # remove tmp file
    if [ -f "_${FILENAME}" ]; then
        ${RM} -f _${FILENAME}
    fi

    cd ../..

    shift
done
