#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CUT="/usr/bin/cut"
EXPR="/usr/bin/expr"
GREP="/bin/grep"
TR="/usr/bin/tr"
WC="/usr/bin/wc"
WGET="/usr/bin/wget"

# -nv: basic option for simple message
# -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
# --no-check-certificate: do not check ssl/cert for https:// url
WGETOPTION="-nv -4 --no-check-certificate"

# WGETUSERAGENT="Wget/1.12"  # default
WGETUSERAGENT="Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-TW; rv:1.9.2.24) Gecko/20111103 Firefox/3.6.24 (.NET CLR 3.5.30729)"  # pretend windows browsers

# referer default none
CLEANREFERER=1

# outfile default none
CLEANOUTFILE=1

while [ ! -z "$1" ]; do
    if [ ${CLEANREFERER} -gt 0 ]; then
        WGETREFERER=""
    fi

    CLEANREFERER=0

    if [ ${CLEANOUTFILE} -gt 0 ]; then
        WGETOUTFILE=""
    fi

    CLEANOUTFILE=0

    # avoid double-typed command
    if [ "wq" = "$1" -o "wq.sh" = "$1" -o "$0" = "$1" ]; then
        shift
        continue
    fi

    # check referer
    CHECKREFERER=`echo "$1" | ${CUT} -c 1-10`
    if [ "--referer=" = "${CHECKREFERER}" ]; then
        WGETREFERER="$1"
        shift
        continue
    fi

    # check outfile
    if [ "-O" = "$1" ]; then
        if [ -z "$2" ]; then
            exit
        fi

        CHECKCOUNT=1
        CHECKOUTFILE=`echo -n "$2"`
        while [ ! -z "${CHECKOUTFILE}" ]; do
            if [ ! -f "${CHECKOUTFILE}" ]; then
                break
            fi

            CHECKOUTFILE=`echo -n "$2.${CHECKCOUNT}"`
            CHECKCOUNT=`${EXPR} ${CHECKCOUNT} + 1`
        done

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
        shift
        shift
        continue
    fi

    # TODO: imgur.com
    # if url: http://imgur.com/Hwrk1Vl
    # get pic: http://i.imgur.com/Hwrk1Vl.jpg
    # check jpg from http://imgur.com/Hwrk1Vl content ?

    # TODO: ppt.cc
    # if url: http://ppt.cc/4Uu-
    # get pic: http://http://ppt.cc/4Uu-@.jpg (maybe [jJ][Pp][Gg] [Gg][Ii][Ff] [Pp][Nn][Gg])
    # check jpg from http://ppt.cc/4Uu- content ?

    # TODO: ppt.cc
    # if url: http://ppt.cc/4Uu-@.jpg without referer
    # auto set referer to http://ppt.cc/4Uu-

    # facebook oh/oe pic
    # if url: https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10489954_760151634035462_3295158177063468216_n.jpg?oh=9d34618b6532a1451cf7816ad38811bd&oe=54599FA2&__gda__=1413965256_cd34923b97f4eb4ad7bb4f1394f9efdb
    # save file into 10489954_760151634035462_3295158177063468216_n.jpg or 10489954_760151634035462_3295158177063468216_n.jpg.N
    CHECKQOH=`echo "$1" | ${GREP} '?oh=' | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKQOH} -gt 0 ]; then
        URL=`echo "$1" | ${AWK} -F\? '{printf("%s",$1);}'`
        BASEFILENAME=`${BASENAME} "${URL}"`

        CHECKCOUNT=1
        CHECKOUTFILE=`echo -n "${BASEFILENAME}"`
        while [ ! -z "${CHECKOUTFILE}" ]; do
            if [ ! -f "${CHECKOUTFILE}" ]; then
                break
            fi

            CHECKOUTFILE=`echo -n "${BASEFILENAME}.${CHECKCOUNT}"`
            CHECKCOUNT=`${EXPR} ${CHECKCOUNT} + 1`
        done

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
    fi

    # facebook dl pic
    # if url: https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10489954_760151634035462_3295158177063468216_n.jpg?dl=1
    # save file into 10489954_760151634035462_3295158177063468216_n.jpg or 10489954_760151634035462_3295158177063468216_n.jpg.N
    CHECKQDL=`echo "$1" | ${GREP} '?dl=' | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKQDL} -gt 0 ]; then
        URL=`echo "$1" | ${AWK} -F\? '{printf("%s",$1);}'`
        BASEFILENAME=`${BASENAME} "${URL}"`

        CHECKCOUNT=1
        CHECKOUTFILE=`echo -n "${BASEFILENAME}"`
        while [ ! -z "${CHECKOUTFILE}" ]; do
            if [ ! -f "${CHECKOUTFILE}" ]; then
                break
            fi

            CHECKOUTFILE=`echo -n "${BASEFILENAME}.${CHECKCOUNT}"`
            CHECKCOUNT=`${EXPR} ${CHECKCOUNT} + 1`
        done

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
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

    # pixiv: get pixture with faked referer
    #   url: http://i2.pixiv.net/img20/img/stargeyser/10931186.jpg?1277014586
    #   ref: http://www.pixiv.net/member_illust.php?mode=big&illust_id=10931186

    if [ 'pixiv' = "${HOSTNAMEB}" -a 'net' = "${HOSTNAMEC}" ]; then
        FILENAME=`echo "${PATHD}" | ${AWK} -F? '{printf("%s",$1);}'`
        FILEID=`echo "${FILENAME}" | ${AWK} -F. '{printf("%d",$1);}'`
        ARGS=`echo "${PATHD}" | ${AWK} -F? '{printf("%s",$2);}'`

        # if url has ? , remove all after ?
        if [ ! -z "${ARGS}" ]; then
            URL=`echo "${URL}" | ${AWK} -F? '{printf("%s",$1);}'`
        fi

        WGETREFERER="--referer=http://www.pixiv.net/member_illust.php?mode=big&illust_id=${FILEID}"
        CLEANREFERER=1
    fi

    # get file first
    ${WGET} ${WGETOUTFILE} ${WGETOPTION} --user-agent="${WGETUSERAGENT}" ${WGETREFERER} "${URL}"

    # TODO:
    # pattern: facebook image
    # url pattern:
    #  1. http://sphotos-e.ak.fbcdn.net/hphotos-ak-prn1/579545_10151765622017074_220805590_n.jpg
    # if get _n.jpg , try get _o.jpg;
    # if got _o.jpg and md5sum of _n.jpg == md5sum of _o.jpg, remove _o.jpg, or reserve both _n.jpg and _o.jpg

    # pattern: tumblr image
    # url pattern:
    #  1. http://25.media.tumblr.com/409bc297bb66a375ac2c85e78d0e387e/tumblr_miu9svkSvK1qk5m6io8_250.jpg
    #  2. http://24.media.tumblr.com/tumblr_kt065fJHvm1qzkcgao1_r1_1280.jpg
    #  3. http://24.media.tumblr.com/tumblr_lp2h0dKA8s1qzn3jqo1_500.jpg
    #  4. TBD

    TUMBLRCOUNT=`echo "$1" | ${GREP} '[0-9].media.tumblr.com/' | ${WC} -l | ${TR} -d ' '`
    if [ $TUMBLRCOUNT -gt 0 ]; then
        HOSTNAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$3);}'`

        # check pattern 1
        FILENAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$5);}'`
        if [ -z "${FILENAME}" ]; then
            # this is pattern 2 or 3
            FILENAME=`echo "$1" | ${AWK} -F/ '{printf("%s",$4);}'`
            PATH=''
        else
            # this is pattern 1
            PATH=`echo "$1" | ${AWK} -F/ '{printf("%s",$4);}'`
            PATH=`echo -n "${PATH}/"`
        fi

        # check pattern 2
        FILENAMESIZE=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s",$4);}'`
        if [ -z "${FILENAMESIZE}" ]; then
            # this is pattern 3
            FILENAMEBODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s",$1,$2);}'`
        else
            # this is pattern 2
            FILENAMEBODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s_%s",$1,$2,$3);}'`
        fi

        FILENAMEEXT=`echo "${FILENAME}" | ${AWK} -F. '{printf("%s",$2);}'`

        # try get bigger size: 1280 1024 800 600
        # maybe there are more bigger size in the future
        for SIZE in 1280 1024 800 600; do
            URL=`echo -n "http://${HOSTNAME}/${PATH}${FILENAMEBODY}_${SIZE}.${FILENAMEEXT}"`
            LOCALFILENAME=`echo -n "${FILENAMEBODY}_${SIZE}.${FILENAMEEXT}"`

            ${WGET} ${WGETOUTFILE} ${WGETOPTION} --user-agent="${WGETUSERAGENT}" ${WGETREFERER} "${URL}"

            # if get a file, skip smaller size
            if [ -f "${LOCALFILENAME}" ]; then
                break
            fi
        done
    fi

    shift
done
