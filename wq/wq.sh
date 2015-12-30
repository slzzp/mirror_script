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
LS="/bin/ls"
MKDIR="/bin/mkdir"
RM="/bin/rm"
SED="/bin/sed"
TR="/usr/bin/tr"
WC="/usr/bin/wc"
WGET="/usr/bin/wget"


wq_get_filename() {
    if [ ! -z "$1" ]; then
        CHECK_COUNT=1
        USE_OUTFILE=`echo -n "$1"`
        while [ ! -z "${USE_OUTFILE}" ]; do
            if [ ! -f "${USE_OUTFILE}" ]; then
                break
            fi

            # file exist but file size is 0, rm it
            if [ ! -s "${USE_OUTFILE}" ]; then
                ${RM} "${USE_OUTFILE}"
                break
            fi

            USE_OUTFILE=`echo -n "$1.${CHECK_COUNT}"`
            CHECK_COUNT=`${EXPR} ${CHECK_COUNT} + 1`
        done
    fi
}

wq_string_has_char() {
    # $1 = string
    # $2 = char
    if [ -z "$1" -o -z "$2" ]; then
        return 0
    fi

    CHECK_CHAR=`echo "$1" | ${GREP} "$2" | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECK_CHAR} -gt 0 ]; then
        return 1
    fi

    return 0
}


# -nv: basic option for simple message
# -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
# --no-check-certificate: do not check ssl/cert for https:// url
WGET_BASE_OPTION="-nv -4 --no-check-certificate"

# USE_USER_AGENT="Wget/1.12"  # default
USE_USER_AGENT="Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-TW; rv:1.9.2.24) Gecko/20111103 Firefox/3.6.24 (.NET CLR 3.5.30729)"  # pretend windows browsers

# referer default none
CLEAN_REFERER=1

# outfile default none
CLEAN_OUTFILE=1

# check if do mkdir first
MKDIR_FIRST=0

while [ ! -z "$1" ]; do
    if [ ${CLEAN_REFERER} -gt 0 ]; then
        SET_REFERER=''
    fi

    CLEAN_REFERER=0

    if [ ${CLEAN_OUTFILE} -gt 0 ]; then
        SET_OUTFILE=''
    fi

    CLEAN_OUTFILE=0
    USE_OUTFILE=''

    # avoid double-typed command
    if [ "wq" = "$1" -o "wq.sh" = "$1" -o "$0" = "$1" ]; then
        shift
        continue
    fi

    # check referer
    CHECK_REFERER=`echo "$1" | ${CUT} -c 1-10`
    if [ '--referer=' = "${CHECK_REFERER}" ]; then
        SET_REFERER="$1"
        shift
        continue
    fi

    # set dir
    if [ '-d' = "$1" ]; then
        shift

        if [ -z "$1" ]; then
            echo "ERROR: empty dir"
            exit
        fi

        if [ ! -d "$1" ]; then
            ${MKDIR} "$1"

            if [ ! -d "$1" ]; then
                echo "ERROR: mkdir fail"
                exit
            fi

            echo "MKDIR $1"
        else
            echo "EXIST $1"
        fi

        if [ -d "$1" ]; then
            MKDIR_FIRST=1
            cd "$1"

            echo "CD $1"
        fi

        shift
        continue
    fi

    # check outfile
    if [ '-O' = "$1" ]; then
        if [ -z "$2" ]; then
            exit
        fi

        wq_get_filename "$2"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
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
    . ~/work/mirror_script/wq/parse_url.sh "${URL}"


    #################################################################
    # TYPE: url is page, get inside pic url                         #
    #################################################################

    # TODO: imgur.com page
    # if url: http://imgur.com/Hwrk1Vl
    #   get pic: http://i.imgur.com/Hwrk1Vl.jpg (maybe [jJ][Pp][Gg] [Gg][Ii][Ff] [Pp][Nn][Gg])
    #   check pic url from http://imgur.com/Hwrk1Vl content ?

    # TODO: ppt.cc page
    # if url: http://ppt.cc/4Uu-
    #   get pic: http://http://ppt.cc/4Uu-@.jpg (maybe [jJ][Pp][Gg] [Gg][Ii][Ff] [Pp][Nn][Gg])
    #   check pic url from http://ppt.cc/4Uu- content ?


    #################################################################
    # TYPE: url is pic, need referer link                           #
    #################################################################

    # huaijiuyingyuan.com pic
    # if url: http://huaijiuyingyuan.com/bbs/UploadFile/2013-6/201361521555920609.jpg
    #   set referer to http://huaijiuyingyuan.com
    if [ 'huaijiuyingyuan.com' = "${HOSTNAME}" ]; then
        SET_REFERER="--referer=http://huaijiuyingyuan.com"
        CLEAN_REFERER=1
    fi

    # ppt.cc pic
    # if url: http://ppt.cc/4Uu-@.jpg without referer
    #   set referer to http://ppt.cc/4Uu-
    if [ 'ppt.cc' = "${HOSTNAME}" ]; then
        wq_string_has_char "${URL}" '@'
        if [ "$?" -gt 0 ]; then
            TMP_REFERER=`echo "${URL}" | ${AWK} -F@ '{printf("%s",$1);}'`

            SET_REFERER="--referer=${TMP_REFERER}"
            CLEAN_REFERER=1
        fi
    fi

    # xuite pic
    # if url: http://5.share.photo.xuite.net/big.max/1580be0/5076492/1041956820_o.jpg
    #   set referer to http://blog.xuite.net/big.max
    if [ 'photo' = "${HOSTNAMEC}" -a 'xuite' = "${HOSTNAMED}" -a 'net' = "${HOSTNAMEE}" ]; then
        SET_REFERER="--referer=http://blog.xuite.net/${PATHA}"
        CLEAN_REFERER=1
    fi

    # pixiv pic
    # if url: http://i2.pixiv.net/img20/img/stargeyser/10931186.jpg?1277014586
    #   set referer to http://www.pixiv.net/member_illust.php?mode=big&illust_id=10931186
    if [ 'pixiv' = "${HOSTNAMEB}" -a 'net' = "${HOSTNAMEC}" ]; then
        # FIXME: get filename from parse_url variables
        FILEID=`echo "${FILENAME}" | ${AWK} -F. '{printf("%d",$1);}'`

        # if url has ? , remove all after ?
        if [ ! -z "${ARGS}" ]; then
            URL=`echo "${URL}" | ${AWK} -F? '{printf("%s",$1);}'`
        fi

        SET_REFERER="--referer=http://www.pixiv.net/member_illust.php?mode=big&illust_id=${FILEID}"
        CLEAN_REFERER=1
    fi


    #################################################################
    # TYPE: url is pic, set saved filename                          #
    #################################################################

    # TODO: cloudfront pic
    # if url: https://dki5ev61kmqpi.cloudfront.net/da02022e02b68ca890a343d6f636f21c3dc34516/687474703a2f2f692e696d6775722e636f6d2f3953716c4167712e6a7067
    #   save file into da02022e02b68ca890a343d6f636f21c3dc34516_687474703a2f2f692e696d6775722e636f6d2f3953716c4167712e6a7067.jpg(.N)

    # facebook dl pic
    # if url: https://scontent-a-nrt.xx.fbcdn.net/hphotos-xpf1/t31.0-8/1272345_163157470544271_1358342518_o.jpg?dl=1
    #   save file into 1272345_163157470544271_1358342518_o.jpg(.N)
    if [ 'dl' = "${ARGAN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # facebook oh/oe pic
    # if url: https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/10489954_760151634035462_3295158177063468216_n.jpg?oh=9d34618b6532a1451cf7816ad38811bd&oe=54599FA2&__gda__=1413965256_cd34923b97f4eb4ad7bb4f1394f9efdb
    #   save file into 10489954_760151634035462_3295158177063468216_n.jpg(.N)
    if [ 'oh' = "${ARGAN}" -a 'oe' = "${ARGBN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # fastpic pic
    # if url: http://www.fastpic.jp/images.php?file=4117028328.jpg
    #   save file into 4117028328.jpg(.N)
    if [ 'www.fastpic.jp' = "${HOSTNAME}" -a 'images.php' = "${FILENAME}" -a 'file' = "${ARGAN}" ]; then
        wq_get_filename "${ARGAV}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: googleusercontent / twavtv pic
    # if url: http://ps.googleusercontent.com/h/www.twavtv.com/classes/image-generator.php?hash=c00698e4241a58820508805410157567&width=600&image=/attachments/month_1207/1207ae39da544f8f702e89596696bad05cea.jpg
    #   save file into 1207ae39da544f8f702e89596696bad05cea.jpg(.N)
    if [ 'ps.googleusercontent.com' = "${HOSTNAME}" -a 'h' = "${PATHA}" -a 'www.twavtv.com' = "${PATHB}" -a 'image-generator.php?hash=c00698e4241a58820508805410157567&width=600&image=' = "${PATHD}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # imgs.cc pic
    # if url: http://s1.imgs.cc/img/Av3i5tq.jpg?jtq
    #   save file into Av3i5tq.jpg(.N)
    if [ 'imgs' = "${HOSTNAMEB}" -a 'cc' = "${HOSTNAMEC}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: miupix pic
    # if url: http://miupix.cc/di/64XFQ7/uploadFromiPhone.jpg
    #   save file into miupix.cc_di-64XFQ7.jpg(.N)

    # pimg pic
    # if url: https://pic.pimg.tw/raindog/1433695157-4225156458.jpg?v=1433695158
    #   save flie into 1433695157-4225156458.jpg(.N)
    if [ 'pic.pimg.tw' = "${HOSTNAME}" -a 'v' = "${ARGAN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # pttbook pic
    # if url: http://cdn.pttbook.com/zhtw/c11477/Image/16f44bfd91d64ad2922b5349d9beb994.jpg%3Fbqt
    #   save file into 16f44bfd91d64ad2922b5349d9beb994.jpg(.N)
    if [ 'cdn.pttbook.com' = "${HOSTNAME}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: twavtv pic
    # if url: http://www.twavtv.com/attachment.php?aid=55082&k=ddf90b96b06a8f3894dea95c508fc5db&t=1409126810&noupdate=yes&sid=93af292dZWRYLMK3GzihH%2FeXvtEbkLpy1JhAmPWk07QJs7I
    #   save file into 55082_ddf90b96b06a8f3894dea95c508fc5db_1409126810_93af292dZWRYLMK3GzihH%2FeXvtEbkLpy1JhAmPWk07QJs7I.jpg(.N)

    # TODO: xuite blog pic
    # if url: http://3.blog.xuite.net/3/0/5/2/232745425/blog_2940195/txt/242605303/2.jpg
    #   save file into 232745425_blog_2940195_242605303_2.jpg(.N)


    #################################################################
    # TYPE: url is pic, replace url                                 #
    #################################################################

    # facebook limited width/height pic
    # if url: https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xpa1/t31.0-8/s960x960/10514307_1450320061902023_7392152021835748963_o.jpg
    #         https://scontent-b-nrt.xx.fbcdn.net/hphotos-xpa1/t1.0-9/p240x240/10313489_415628195241707_2675330737228852867_n.jpg
    #   replace url: https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xpa1/t31.0-8/10514307_1450320061902023_7392152021835748963_o.jpg
    CHECKFBS=`echo "${URL}" | ${GREP} '/[ps][0-9][0-9]*x[0-9][0-9]*/' | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKFBS} -gt 0 ]; then
        URL=`echo -n "${URL}" | ${SED} 's/\/[ps][0-9][0-9]*x[0-9][0-9]*\//\//g'`
    fi

    # TODO: taiwanacgn.net pic
    # if url: https://taiwanacgn.net/wp-content/uploads/2015/09/431387eb7262e1cfc79b125eb8a67c60451.jpg
    #   replace url: http://taiwanacgn.net/wp-content/uploads/2015/09/431387eb7262e1cfc79b125eb8a67c60451.jpg

    # TODO: udn pic
    # if url: http://pgw.udn.com.tw/gw/photo.php?u=http://uc.udn.com.tw/photo/2015/10/09/realtime/1392155.jpg
    #   replace url: http://uc.udn.com.tw/photo/2015/10/09/realtime/1392155.jpg


    # get file first
    ${WGET} ${SET_OUTFILE} ${WGET_BASE_OPTION} --user-agent="${USE_USER_AGENT}" ${SET_REFERER} "${URL}"

    # if filesize is 0, remove it
    if [ ! -z "${USE_OUTFILE}" -a -f "${USE_OUTFILE}" -a ! -s "${USE_OUTFILE}" ]; then
        ${RM} "${USE_OUTFILE}"
    fi


    #################################################################
    # TYPE: url is pic, get more pics by changing url               #
    #################################################################

    # tumblr pic
    # if url:
    #  1. http://25.media.tumblr.com/409bc297bb66a375ac2c85e78d0e387e/tumblr_miu9svkSvK1qk5m6io8_250.jpg
    #  2. http://24.media.tumblr.com/tumblr_kt065fJHvm1qzkcgao1_r1_1280.jpg
    #  3. http://24.media.tumblr.com/tumblr_lp2h0dKA8s1qzn3jqo1_500.jpg
    #  4. TBD
    if [ 'media' = "${HOSTNAMEB}" -a 'tumblr' = "${HOSTNAMEC}" -a 'com' = "${HOSTNAMED}" ]; then
        if [ -z "${PATHB}" ]; then
            # url 2 or 3
            MORE_PATH=''
        else
            # url 1
            MORE_PATH="${PATHA}/"
        fi

        # check url 2
        FILENAME_SIZE=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s",$4);}'`
        if [ -z "${FILENAME_SIZE}" ]; then
            # url 3
            FILENAME_BODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s",$1,$2);}'`
        else
            # url 2
            FILENAME_BODY=`echo "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s_%s",$1,$2,$3);}'`
        fi

        # try get bigger size: 1280 1024 800 600
        # maybe there are more bigger size in the future
        for MORE_SIZE in 1280 1024 800 600; do
            MORE_URL=`echo -n "${PROTOCOL}://${HOSTNAME}/${MORE_PATH}${FILENAME_BODY}_${MORE_SIZE}.${FILENAMEEXT}"`

            wq_get_filename "${FILENAME_BODY}_${MORE_SIZE}.${FILENAMEEXT}"

            SET_OUTFILE="-O ${USE_OUTFILE}"
            CLEAN_OUTFILE=1

            ${WGET} ${SET_OUTFILE} ${WGET_BASE_OPTION} --user-agent="${USE_USER_AGENT}" ${SET_REFERER} "${MORE_URL}"

            # if filesize is 0, remove it
            if [ ! -z "${USE_OUTFILE}" -a -f "${USE_OUTFILE}" -a ! -s "${USE_OUTFILE}" ]; then
                ${RM} "${USE_OUTFILE}"
                echo "RE-GET ${URL}"
                continue
            fi

            # if get a file, skip smaller size
            if [ -s "${USE_OUTFILE}" ]; then
                break
            fi
        done
    fi

    # TODO: twimg pic
    # if url: http://pbs.twimg.com/media/CRwQEeDUcAAR_Hd.jpg
    #   get http://pbs.twimg.com/media/CRwQEeDUcAAR_Hd.jpg:orig
    #   compare CRwQEeDUcAAR_Hd.jpg and CRwQEeDUcAAR_Hd.jpg:large
    #   if same, remove CRwQEeDUcAAR_Hd.jpg:orig else remove CRwQEeDUcAAR_Hd.jpg

    shift
done


# auto remove duplicate files
if [ ${MKDIR_FIRST} -gt 0 ]; then
    ~/work/mirror_script/wq/rmdotdup.sh
    ~/work/mirror_script/wq/rmdirdup.sh ../

    if [ -d '../../ad9' ]; then
        ~/work/mirror_script/wq/rmdirdup.sh ../../ad9/
    fi

    if [ -d '../../../ad9' ]; then
        ~/work/mirror_script/wq/rmdirdup.sh ../../../ad9/
    fi

    echo "file count: `${LS} | ${WC} -l`"
fi
