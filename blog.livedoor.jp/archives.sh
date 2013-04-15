#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
CAT="/bin/cat"
CUT="/usr/bin/cut"
GREP="/bin/grep"
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


while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "$0" == "$1" ]; then
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
    HOSTNAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$3);}'`
    USERNAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$4);}'`
    FILENAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$6);}'`
    FILEID=`echo "$1" | ${AWK} -F/ '{printf("%s",$6);}' | ${AWK} -F\. '{printf("%d",$1);}'`

    cd ~/tmp/

    # build dir
    ${MKDIR} -p ${HOSTNAME}/${USERNAME}/${FILEID}

    cd ${HOSTNAME}/${USERNAME}/${FILEID}

    # remove old html file first
    if [ -f "${FILENAME}" ]; then
        ${RM} -f ${FILENAME}
    fi

    # remove tmp file
    if [ -f "_${FILENAME}" ]; then
        ${RM} -f _${FILENAME}
    fi

    # get html file
    ${WGET} ${WGETOPTION} ${WGETREFERER} "${URL}"

    # filt content images url
    ${CAT} ${FILENAME} | \
      ${GREP} -B 10000 'article-footer' | \
      ${GREP} -A 10000 'article-body' | \
      ${SED} 's/></>\n</g' | \
      ${GREP} http://livedoor.blogimg.jp/${USERNAME}/imgs/ | \
      ${GREP} -v -- 'margin-bottom' | \
      ${GREP} -v '/http://' | \
      ${GREP} -v -- '-s.jpg' \
      > _${FILENAME}

    # get images
    ${WGET} ${WGETOPTION} -F -i _${FILENAME}

    # remove tmp file
    if [ -f "_${FILENAME}" ]; then
        ${RM} -f _${FILENAME}
    fi


    cd ../../..

    shift
done
