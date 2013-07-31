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
    # http://album.blog.yam.com/show.php?a=death1121&f=9939631&i=24590367&p=160
    HOSTNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$3);}'`
    PATHARGS=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
    PATHFILE=`echo "${PATHARGS}" | ${AWK} -F\? '{printf("%s",$1);}'`
    ARGS=`echo "${PATHARGS}" | ${AWK} -F\? '{printf("%s",$2);}'`

    USERNAME=""
    FOLDERID=""
    PAGEAT=""

    for ARGNAMEVALUE in `echo "${ARGS}" | ${TR} '&' ' '`; do
        ARGNAME=`echo "${ARGNAMEVALUE}" | ${AWK} -F= '{printf("%s",$1);}'`
        ARGVALUE=`echo "${ARGNAMEVALUE}" | ${AWK} -F= '{printf("%s",$2);}'`
        # echo "arg name/value: ${ARGNAME} ${ARGVALUE}"

        if [ "a" = "${ARGNAME}" ]; then
            USERNAME="${ARGVALUE}";
        fi

        if [ "f" = "${ARGNAME}" ]; then
            FOLDERID="${ARGVALUE}";
        fi

        if [ "p" = "${ARGNAME}" ]; then
            PAGEAT="${ARGVALUE}";
        fi
    done

    echo "check: username: [${USERNAME}]  folder id: [${FOLDERID}]  page: [${PAGEAT}]"

    if [ -z "${USERNAME}" -o -z "${FOLDERID}" ]; then
        echo "wrong url: ${URL}"
        exit
    fi

    FILENAME="page_${PAGEAT}_$$.html"


    cd ~/tmp/

    # build dir
    ${MKDIR} -p album.blog.yam.com/${USERNAME}/${FOLDERID}

    cd album.blog.yam.com/${USERNAME}/${FOLDERID}


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


    # remove tmp page file
    if [ -f "__${FILENAME}" ]; then
        ${RM} -f __${FILENAME}
    fi

    # parse img link
    ${CAT} _${FILENAME} | \
      ${GREP} -A 1 pixWrap | \
      ${GREP} '<img ' \
      > __${FILENAME}

    if [ ! -s "__${FILENAME}" ]; then
        echo "parse img link error, url: ${URL}"
        ${RM} -f ${FILENAME} _${FILENAME} __${FILENAME}
        exit
    fi

    # get image
    ${WGET} ${WGETOPTION} --referer="${WGETREFERER}" -F -i __${FILENAME}

    # remove tmp page file
    if [ -f "__${FILENAME}" ]; then
        ${RM} -f __${FILENAME}
    fi


    # remove old html file first
    if [ -f "${FILENAME}" ]; then
        ${RM} -f ${FILENAME}
    fi

    # remove tmp file
    if [ -f "_${FILENAME}" ]; then
        ${RM} -f _${FILENAME}
    fi

    cd ../../..

    shift
done
