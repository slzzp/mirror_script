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
SED="/bin/sed"
TR="/usr/bin/tr"
WC="/usr/bin/wc"
WGET="/usr/bin/wget"


wq_get_filename() {
    if [ ! -z "$1" ]; then
        CHECKCOUNT=1
        CHECKOUTFILE=`echo -n "$1"`
        while [ ! -z "${CHECKOUTFILE}" ]; do
            if [ ! -f "${CHECKOUTFILE}" ]; then
                break
            fi

            if [ ! -s "${CHECKOUTFILE}" ]; then
                ${RM} "${CHECKOUTFILE}"
                break
            fi

            CHECKOUTFILE=`echo -n "$1.${CHECKCOUNT}"`
            CHECKCOUNT=`${EXPR} ${CHECKCOUNT} + 1`
        done
    fi
}

wq_string_has_char() {
    # $1 = string
    # $2 = char
    if [ -z "$1" -o -z "$2" ]; then
        return 0
    fi

    CHECKCHAR=`echo "$1" | ${GREP} "$2" | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKCHAR} -gt 0 ]; then
        return 1
    fi

    return 0
}


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
    CHECKOUTFILE=''

    # avoid double-typed command
    if [ "wq" = "$1" -o "wq.sh" = "$1" -o "$0" = "$1" ]; then
        shift
        continue
    fi

    # check referer
    CHECKREFERER=`echo "$1" | ${CUT} -c 1-10`
    if [ '--referer=' = "${CHECKREFERER}" ]; then
        WGETREFERER="$1"
        shift
        continue
    fi

    # check outfile
    if [ '-O' = "$1" ]; then
        if [ -z "$2" ]; then
            exit
        fi

        wq_get_filename "$2"

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
        shift
        shift
        continue
    fi


    # preprocess url
    URL=`echo -n "$1"`

    # check if $1's prefix is '//'
    CHECKSLASHSLASH=`echo "$1" | ${CUT} -c 1-2`
    if [ "//" = "${CHECKSLASHSLASH}" ]; then
        URL=`echo -n "http:$1"`
    fi


    # parse url
    PROTOCOL=`echo "${URL}" | ${AWK} -F: '{printf("%s",$1);}'`
    HOSTNAME=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$3);}'`
    HOSTNAMEA=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$1);}'`
    HOSTNAMEB=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$2);}'`
    HOSTNAMEC=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$3);}'`
    HOSTNAMED=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$4);}'`
    PATHA=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
    PATHB=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$5);}'`
    PATHC=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$6);}'`
    PATHD=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$7);}'`
    FILENAMEARG=`${BASENAME} "${URL}"`
    FILENAME=`echo "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$1);}'`
    FILENAMEEXT=`echo "${FILENAME}" | ${AWK} -F. '{printf("%s", $NF);}'`
    ARGS=`echo "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$2);}'`
    ARGA=`echo "${ARGS}" | ${AWK} -F\& '{printf("%s",$1);}'`
    ARGAN=`echo "${ARGA}" | ${AWK} -F= '{printf("%s",$1);}'`
    ARGAV=`echo "${ARGA}" | ${AWK} -F= '{printf("%s",$2);}'`
    ARGB=`echo "${ARGS}" | ${AWK} -F\& '{printf("%s",$2);}'`
    ARGBN=`echo "${ARGB}" | ${AWK} -F= '{printf("%s",$1);}'`
    ARGBV=`echo "${ARGB}" | ${AWK} -F= '{printf("%s",$2);}'`


    # TODO: imgur.com
    # if url: http://imgur.com/Hwrk1Vl
    # get pic: http://i.imgur.com/Hwrk1Vl.jpg
    # check jpg from http://imgur.com/Hwrk1Vl content ?


    # ppt.cc
    # 1. pic file
    #    if url: http://ppt.cc/4Uu-@.jpg without referer
    #    auto set referer to http://ppt.cc/4Uu-
    # 2. get pic file
    #    if url: http://ppt.cc/4Uu-
    #    get pic: http://http://ppt.cc/4Uu-@.jpg (maybe [jJ][Pp][Gg] [Gg][Ii][Ff] [Pp][Nn][Gg])
    #    check jpg from http://ppt.cc/4Uu- content ?
    if [ 'ppt.cc' = "${HOSTNAME}" ]; then
        wq_string_has_char "${URL}" '@'
        if [ "$?" -gt 0 ]; then
            TMPREFERER=`echo "${URL}" | ${AWK} -F@ '{printf("%s",$1);}'`

            WGETREFERER="--referer=${TMPREFERER}"
            CLEANREFERER=1
        else
            echo 'TODO'
            shift
            continue
        fi
    fi


    # fastpic image
    # if url: http://www.fastpic.jp/images.php?file=4117028328.jpg
    # save file into 4117028328.jpg or 4117028328.jpg.N
    if [ 'www.fastpic.jp' = "${HOSTNAME}" -a 'images.php' = "${FILENAME}" -a 'file' = "${ARGAN}" ]; then
        wq_get_filename "${ARGAV}"

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
    fi


    # facebook oh/oe pic
    # if url: https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10489954_760151634035462_3295158177063468216_n.jpg?oh=9d34618b6532a1451cf7816ad38811bd&oe=54599FA2&__gda__=1413965256_cd34923b97f4eb4ad7bb4f1394f9efdb
    # save file into 10489954_760151634035462_3295158177063468216_n.jpg or 10489954_760151634035462_3295158177063468216_n.jpg.N
    if [ 'oh' = "${ARGAN}" -a 'oe' = "${ARGBN}" ]; then
        wq_get_filename "${FILENAME}"

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
    fi


    # facebook dl pic
    # if url: https://scontent-a-nrt.xx.fbcdn.net/hphotos-xpf1/t31.0-8/1272345_163157470544271_1358342518_o.jpg?dl=1
    # save file into 1272345_163157470544271_1358342518_o.jpg or 1272345_163157470544271_1358342518_o.jpg.N
    if [ 'dl' = "${ARGAN}" ]; then
        wq_get_filename "${FILENAME}"

        WGETOUTFILE="-O ${CHECKOUTFILE}"
        CLEANOUTFILE=1
    fi


    # facebook limited width/height pic
    # if url: https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xpa1/t31.0-8/s960x960/10514307_1450320061902023_7392152021835748963_o.jpg
    #         https://scontent-b-nrt.xx.fbcdn.net/hphotos-xpa1/t1.0-9/p240x240/10313489_415628195241707_2675330737228852867_n.jpg
    # update url: https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xpa1/t31.0-8/10514307_1450320061902023_7392152021835748963_o.jpg
    CHECKFBS=`echo "${URL}" | ${GREP} '/[ps][0-9][0-9]*x[0-9][0-9]*/' | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKFBS} -gt 0 ]; then
        URL=`echo -n "${URL}" | ${SED} 's/\/[ps][0-9][0-9]*x[0-9][0-9]*\//\//g'`
    fi


    # pixiv: get pixture with faked referer
    #   url: http://i2.pixiv.net/img20/img/stargeyser/10931186.jpg?1277014586
    #   ref: http://www.pixiv.net/member_illust.php?mode=big&illust_id=10931186
    if [ 'pixiv' = "${HOSTNAMEB}" -a 'net' = "${HOSTNAMEC}" ]; then
        FILEID=`echo "${FILENAME}" | ${AWK} -F. '{printf("%d",$1);}'`

        # if url has ? , remove all after ?
        if [ ! -z "${ARGS}" ]; then
            URL=`echo "${URL}" | ${AWK} -F? '{printf("%s",$1);}'`
        fi

        WGETREFERER="--referer=http://www.pixiv.net/member_illust.php?mode=big&illust_id=${FILEID}"
        CLEANREFERER=1
    fi


    # get file first
    ${WGET} ${WGETOUTFILE} ${WGETOPTION} --user-agent="${WGETUSERAGENT}" ${WGETREFERER} "${URL}"

    # if filesize is 0, remove it
    if [ ! -z "${CHECKOUTFILE}" -a -f "${CHECKOUTFILE}" -a ! -s "${CHECKOUTFILE}" ]; then
        ${RM} "${CHECKOUTFILE}"
    fi

    # pattern: tumblr image
    # url pattern:
    #  1. http://25.media.tumblr.com/409bc297bb66a375ac2c85e78d0e387e/tumblr_miu9svkSvK1qk5m6io8_250.jpg
    #  2. http://24.media.tumblr.com/tumblr_kt065fJHvm1qzkcgao1_r1_1280.jpg
    #  3. http://24.media.tumblr.com/tumblr_lp2h0dKA8s1qzn3jqo1_500.jpg
    #  4. TBD
    if [ 'media' = "${HOSTNAMEB}" -a 'tumblr' = "${HOSTNAMEC}" -a 'com' = "${HOSTNAMED}" ]; then
        if [ -z "${PATHB}" ]; then
            # pattern 2 or 3
            PATH=''
        else
            # pattern 1
            PATH="${PATHA}/"
        fi

        # check pattern 2
        FILENAMESIZE=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s",$4);}'`
        if [ -z "${FILENAMESIZE}" ]; then
            # pattern 3
            FILENAMEBODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s",$1,$2);}'`
        else
            # pattern 2
            FILENAMEBODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s_%s",$1,$2,$3);}'`
        fi

        # try get bigger size: 1280 1024 800 600
        # maybe there are more bigger size in the future
        for SIZE in 1280 1024 800 600; do
            LOCALURL=`echo -n "${PROTOCOL}://${HOSTNAME}/${PATH}${FILENAMEBODY}_${SIZE}.${FILENAMEEXT}"`

            wq_get_filename "${FILENAMEBODY}_${SIZE}.${FILENAMEEXT}"

            WGETOUTFILE="-O ${CHECKOUTFILE}"
            CLEANOUTFILE=1

            ${WGET} ${WGETOUTFILE} ${WGETOPTION} --user-agent="${WGETUSERAGENT}" ${WGETREFERER} "${LOCALURL}"

            # if filesize is 0, remove it
            if [ ! -z "${CHECKOUTFILE}" -a -f "${CHECKOUTFILE}" -a ! -s "${CHECKOUTFILE}" ]; then
                ${RM} "${CHECKOUTFILE}"
            fi

            # if get a file, skip smaller size
            if [ -s "${CHECKOUTFILE}" ]; then
                break
            fi
        done
    fi

    shift
done
