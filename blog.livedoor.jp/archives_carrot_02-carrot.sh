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
MV="/bin/mv"
RM="/bin/rm"
SED="/bin/sed"
TR="/usr/bin/tr"
WC="/usr/bin/wc"
WGET="/usr/bin/wget"


# -nv: basic option for simple message
# -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
# --no-check-certificate: do not check ssl/cert for https:// url
WGETOPTION="-nv -4 --no-check-certificate"


MYNAME='carrot_02-carrot'

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
    HOSTNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$3);}'`
    USERNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
    FILENAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$6);}'`
    FILEID=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$6);}' | ${AWK} -F\. '{printf("%d",$1);}'`

    if [ "${MYNAME}" != "${USERNAME}" ]; then
        ~/work/mirror_script/blog.livedoor.jp/archives.sh "${URL}"
        shift
        continue
    fi

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
    while [ 1 -eq 1 ]; do
        # http://blog.livedoor.jp/carrot_02-carrot/archives/6389067.html
        BEGINCOUNT=`${GREP} -- '<div class="main">' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        ENDCOUNT=`${GREP} -- 'AD700px --' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        if [ ${BEGINCOUNT} -gt 0 -a ${ENDCOUNT} -gt 0 ]; then
            ${CAT} ${FILENAME} | \
              ${SED} 's/></>\n</g' | \
              ${GREP} -m 1 -A 10000 -- '<div class="main">' | \
              ${GREP} -m 1 -B 10000 -- 'AD700px --' | \
              ${GREP} -i -e 'jpg' -e 'jpeg' -e 'png' -e 'gif' | \
                ${GREP} -v -- ' alt="check-' | \
                ${GREP} -v -- ' alt="piclogo' | \
                ${GREP} -v -- ' alt=check-' | \
                ${GREP} -v -- ' alt=piclogo' | \
              ${GREP} -v -- '/http://' | \
              ${GREP} -v -- '\.js' | \
              ${GREP} -v -- '\.html' | \
              ${GREP} -v -- '-s\.png' | \
              ${GREP} -v -- '-s\.jpg' \
              > _${FILENAME}
            break
        fi

        #
        BEGINCOUNT=`${GREP} -- '<div class="main">' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        ENDCOUNT=`${GREP} -- '90d839fa-s.gif' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        if [ ${BEGINCOUNT} -gt 0 -a ${ENDCOUNT} -gt 0 ]; then
            ${CAT} ${FILENAME} | \
              ${SED} 's/></>\n</g' | \
              ${GREP} -m 1 -A 10000 -- '<div class="main">' | \
              ${GREP} -m 1 -B 10000 -- '90d839fa-s.gif' | \
              ${GREP} -i -e 'jpg' -e 'jpeg' -e 'png' -e 'gif' | \
                ${GREP} -v -- '90d839fa-s.gif' | \
                ${GREP} -v -- ' alt="check-' | \
                ${GREP} -v -- ' alt="piclogo' | \
                ${GREP} -v -- ' alt=check-' | \
                ${GREP} -v -- ' alt=piclogo' | \
              ${GREP} -v -- '/http://' | \
              ${GREP} -v -- '\.js' | \
              ${GREP} -v -- '\.html' | \
              ${GREP} -v -- '-s\.png' | \
              ${GREP} -v -- '-s\.jpg' \
              > _${FILENAME}
            break
        fi

        #
        BEGINCOUNT=`${GREP} -- '<div class="main">' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        ENDCOUNT=`${GREP} -- '94110045.gif' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        if [ ${BEGINCOUNT} -gt 0 -a ${ENDCOUNT} -gt 0 ]; then
            ${CAT} ${FILENAME} | \
              ${SED} 's/></>\n</g' | \
              ${GREP} -m 1 -A 10000 -- '<div class="main">' | \
              ${GREP} -m 1 -B 10000 -- '94110045.gif' | \
              ${GREP} -i -e 'jpg' -e 'jpeg' -e 'png' -e 'gif' | \
                ${GREP} -v -- '94110045.gif' | \
                ${GREP} -v -- ' alt="check-' | \
                ${GREP} -v -- ' alt="piclogo' | \
                ${GREP} -v -- ' alt=check-' | \
                ${GREP} -v -- ' alt=piclogo' | \
              ${GREP} -v -- '/http://' | \
              ${GREP} -v -- '\.js' | \
              ${GREP} -v -- '\.html' | \
              ${GREP} -v -- '-s\.png' | \
              ${GREP} -v -- '-s\.jpg' \
              > _${FILENAME}
            break
        fi

        #
        BEGINCOUNT=`${GREP} -- '<div class="main">' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        ENDCOUNT=`${GREP} -- 'c0776072.jpg' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        if [ ${BEGINCOUNT} -gt 0 -a ${ENDCOUNT} -gt 0 ]; then
            ${CAT} ${FILENAME} | \
              ${SED} 's/></>\n</g' | \
              ${GREP} -m 1 -A 10000 -- '<div class="main">' | \
              ${GREP} -m 1 -B 10000 -- 'c0776072.jpg' | \
              ${GREP} -i -e 'jpg' -e 'jpeg' -e 'png' -e 'gif' | \
                ${GREP} -v -- 'c0776072.jpg' | \
                ${GREP} -v -- ' alt="check-' | \
                ${GREP} -v -- ' alt="piclogo' | \
                ${GREP} -v -- ' alt=check-' | \
                ${GREP} -v -- ' alt=piclogo' | \
              ${GREP} -v -- '/http://' | \
              ${GREP} -v -- '\.js' | \
              ${GREP} -v -- '\.html' | \
              ${GREP} -v -- '-s\.png' | \
              ${GREP} -v -- '-s\.jpg' \
              > _${FILENAME}
            break
        fi

        #
        BEGINCOUNT=`${GREP} -- '<div class="main">' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        ENDCOUNT=`${GREP} -- 'brog-bana700.gif' ${FILENAME} | ${WC} -l | ${TR} -d ' '`
        if [ ${BEGINCOUNT} -gt 0 -a ${ENDCOUNT} -gt 0 ]; then
            ${CAT} ${FILENAME} | \
              ${SED} 's/></>\n</g' | \
              ${GREP} -m 1 -A 10000 -- '<div class="main">' | \
              ${GREP} -m 1 -B 10000 -- 'brog-bana700.gif' | \
              ${GREP} -i -e 'jpg' -e 'jpeg' -e 'png' -e 'gif' | \
                ${GREP} -v -- 'brog-bana700.gif' | \
                ${GREP} -v -- ' alt="check-' | \
                ${GREP} -v -- ' alt="piclogo' | \
                ${GREP} -v -- ' alt=check-' | \
                ${GREP} -v -- ' alt=piclogo' | \
              ${GREP} -v -- '/http://' | \
              ${GREP} -v -- '\.js' | \
              ${GREP} -v -- '\.html' | \
              ${GREP} -v -- '-s\.png' | \
              ${GREP} -v -- '-s\.jpg' \
              > _${FILENAME}
            break
        fi

        echo "unknown html structure: ${URL}"
        exit
    done

    # global filter
    ${CAT} _${FILENAME} | \
      ${GREP} -v -- 'img.e-nls.com' | \
      ${GREP} -v -- '.com/ad/' | \
      ${GREP} -v -- '.dtiserv.com/' \
      > __${FILENAME}
    ${MV} __${FILENAME} _${FILENAME}

    # get images
    ${WGET} ${WGETOPTION} --referer="${URL}" -F -i _${FILENAME}

    cd ../../..

    shift
done
