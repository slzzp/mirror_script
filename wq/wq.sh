#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
. ~/work/mirror_script/cmd.sh


wq_get_filename() {
    if [ ! -z "$1" ]; then
        CHECK_COUNT=1
        USE_OUTFILE=`${ECHO} -n "$1"`
        while [ ! -z "${USE_OUTFILE}" ]; do
            if [ ! -f "${USE_OUTFILE}" ]; then
                break
            fi

            # file exist but file size is 0, rm it
            if [ ! -s "${USE_OUTFILE}" ]; then
                ${RM} "${USE_OUTFILE}"
                break
            fi

            USE_OUTFILE=`${ECHO} -n "$1.${CHECK_COUNT}"`
            CHECK_COUNT=`${EXPR} ${CHECK_COUNT} + 1`
        done
    fi
}

wq_get_new_filename() {
    if [ ! -z "$1" -a ! -z "$2" ]; then
        CHECK_COUNT=1
        NEW_OUTFILE=`${ECHO} -n "$1"`
        while [ ! -z "${NEW_OUTFILE}" ]; do
            if [ ! -f "${NEW_OUTFILE}" ]; then
                break
            fi

            # file exist but file size is 0, rm it
            if [ ! -s "${NEW_OUTFILE}" ]; then
                ${RM} "${NEW_OUTFILE}"
                break
            fi

            NEW_OUTFILE=`${ECHO} -n "$1.${CHECK_COUNT}"`
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

    CHECK_CHAR=`${ECHO} "$1" | ${GREP} "$2" | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECK_CHAR} -gt 0 ]; then
        return 1
    fi

    return 0
}


# -nv: basic option for simple message
# -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
# --no-check-certificate: do not check ssl/cert for https:// url
WGET_BASE_OPTION="-nv -4 --no-check-certificate "

# USE_USER_AGENT="Wget/1.12"  # default
USE_USER_AGENT="Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-TW; rv:1.9.2.24) Gecko/20111103 Firefox/3.6.24 (.NET CLR 3.5.30729)"  # pretend windows browsers

# referer default none
CLEAN_REFERER=1

# outfile default none
CLEAN_OUTFILE=1

# check file type and rename
CHECK_FILETYPE=0

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
    CHECK_REFERER=`${ECHO} "$1" | ${CUT} -c 1-10`
    if [ '--referer=' = "${CHECK_REFERER}" ]; then
        SET_REFERER="$1"
        shift
        continue
    fi


    # set dir
    if [ '-d' = "$1" ]; then
        shift

        if [ -z "$1" ]; then
            ${ECHO} "ERROR: empty dir"
            exit
        fi

        DESTDIR=`${ECHO} -n "$1"`

        # convert url dir
        CHECKHTTP=`${ECHO} $1 | ${CUT} -c 1-7`
        if [ 'http://' = "${CHECKHTTP}" -o 'https:/' = "${CHECKHTTP}" ]; then
            . ~/work/mirror_script/parse_url.sh "${DESTDIR}"

            # twitter / x dir
            # home dir 1: https://x.com/icecream0813
            # home dir 2: https://x.com/icecream0813/
            # single pic: https://x.com/icecream0813/status/1903590012941115583/photo/1
            # banner pic: https://x.com/icecream0813/header_photo
            # -> twitter/icecream0813
            # multiple pics: https://twitter.com/kagitari/status/791152666806198272
            # -> twitter/kagitari/791152666806198272
            if [ 'twitter.com' = "${HOSTNAME}" -o 'x.com' = "${HOSTNAME}" ]; then
                if [ "${PATHA}" = "${FILENAME}" ]; then
                    DESTDIR="twitter/${FILENAME}"
                elif [ 'header_photo' = "${PATHB}" ]; then
                    DESTDIR="twitter/${PATHA}"
                elif [ 'status' = "${PATHB}" ]; then
                    if [ 'photo' = "${PATHD}" ]; then
                        DESTDIR="twitter/${PATHA}"
                    else
                        DESTDIR="twitter/${PATHA}/${FILENAME}"
                    fi
                fi
            fi

            # http://photo.beautyleg.com/album/70-No1fVl/0000.jpg -> 70-No1fVl
            if [ 'photo.beautyleg.com' = "${HOSTNAME}" ]; then
                DESTDIR="${PATHB}"
            fi
        fi

        if [ ! -d "${DESTDIR}" ]; then
            ${MKDIR} -p "${DESTDIR}"

            if [ ! -d "${DESTDIR}" ]; then
                ${ECHO} "ERROR: mkdir fail"
                exit
            fi

            ${ECHO} "MKDIR ${DESTDIR}"
        else
            ${ECHO} "EXIST ${DESTDIR}"
        fi

        if [ -d "${DESTDIR}" ]; then
            MKDIR_FIRST=1
            cd "${DESTDIR}"

            ${ECHO} "CD ${DESTDIR}"
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
    URL=`${ECHO} -n "$1"`

    # check if $1's prefix is '//'
    CHECKSLASHSLASH=`${ECHO} "$1" | ${CUT} -c 1-2`
    if [ "//" = "${CHECKSLASHSLASH}" ]; then
        URL=`${ECHO} -n "http:$1"`
    fi


    # parse url
    . ~/work/mirror_script/parse_url.sh "${URL}"


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

    # TODO: gifspace.net page
    # if url: http://gifspace.net/image/atgQc
    #   get pic: http://gifspace.net/image/atgQc.gif

    # TODO: giphy.com page
    # if url: https://giphy.com/gifs/l4FGDTpSelVaeGwms
    #   get pic: https://media.giphy.com/media/l4FGDTpSelVaeGwms/giphy.gif


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
            TMP_REFERER=`${ECHO} "${URL}" | ${AWK} -F@ '{printf("%s",$1);}'`

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
        FILEID=`${ECHO} "${FILENAME}" | ${AWK} -F. '{printf("%d",$1);}'`

        # if url has ? , remove all after ?
        if [ ! -z "${ARGS}" ]; then
            URL=`${ECHO} "${URL}" | ${AWK} -F? '{printf("%s",$1);}'`
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

    # twitter / x banner pic
    # if url: https://pbs.twimg.com/profile_banners/2935975597/1705805388/1500x500
    #  save file into 2935975597_1705805388_1500x500.jpg
    if [ 'pbs.twimg.com' = "${HOSTNAME}" -a 'profile_banners' = "${PATHA}" ]; then
        wq_get_filename "${PATHB}_${PATHC}_${FILENAME}.jpg"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # twitter / x pic
    # if url: https://pbs.twimg.com/media/Gmpvz9Ga0AAr81E?format=jpg&name=large
    #  save file into Gmpvz9Ga0AAr81E_large.jpg
    if [ 'pbs.twimg.com' = "${HOSTNAME}" -a 'media' = "${PATHA}" -a \
         'format' = "${ARGAN}" -a 'name' = "${ARGBN}" ]; then
        wq_get_filename "${FILENAME}_${ARGBV}.${ARGAV}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

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

    # facebook pic 10-1
    # if url: https://scontent.ftpe7-3.fna.fbcdn.net/v/t39.30808-6/487688187_1060350909462279_1092799556167713298_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=127cfc&_nc_ohc=29YY9CtkK-sQ7kNvwE5OeIN&_nc_oc=Adkwq5BwUr9q7Pxr_bkIVaA8rJHf_26f_G7CdyKfAP2R6_iV-aPl-p2i7_jJuuboh6Q&_nc_zt=23&_nc_ht=scontent.ftpe7-3.fna&_nc_gid=uo2V05yPmFAtvIXpPVqFLg&oh=00_AfFRPu2jM9RO-gezKaG9dK9G-3y9aiYAlI5fmNbDo6dDPg&oe=67F84DF7
    #  save file into 487688187_1060350909462279_1092799556167713298_n.jpg
    if [ '_nc_cat' = "${ARGAN}" -a 'ccb' = "${ARGBN}" -a '_nc_sid' = "${ARGCN}" -a '_nc_ohc' = "${ARGDN}" -a \
         '_nc_oc' = "${ARGEN}" -a '_nc_zt' = "${ARGFN}" -a '_nc_ht' = "${ARGGN}" -a '_nc_gid' = "${ARGHN}" -a \
         'oh' = "${ARGIN}" -a 'oe' = "${ARGJN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # facebook pic 11-1
    # if url: https://scontent.ftpe7-3.fna.fbcdn.net/v/t39.30808-6/481250674_10221417861194933_2523638107343556422_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=103&ccb=1-7&_nc_sid=aa7b47&_nc_ohc=pMsG6ZFYugkQ7kNvwEFljVr&_nc_oc=Adm__IPtlwY0beT8qu2MLJz6Rrpf4kO9WIbUr09yu6Rn8jyI_KP9v4jQK96KpbPFGK4&_nc_zt=23&_nc_ht=scontent.ftpe7-3.fna&_nc_gid=4x2LjCYCfs93nwhdZpH6kw&oh=00_AfFsZODIfCNC5fYG368J7LnDejatbd0n14Ksg_YZHg-O0w&oe=67FC9D72
    #  save file into 481250674_10221417861194933_2523638107343556422_n.jpg
    if [ 'stp' = "${ARGAN}" -a \
         '_nc_cat' = "${ARGBN}" -a 'ccb' = "${ARGCN}" -a '_nc_sid' = "${ARGDN}" -a '_nc_ohc' = "${ARGEN}" -a \
         '_nc_oc' = "${ARGFN}" -a '_nc_zt' = "${ARGGN}" -a '_nc_ht' = "${ARGHN}" -a '_nc_gid' = "${ARGIN}" -a \
         'oh' = "${ARGJN}" -a 'oe' = "${ARGKN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # facebook pic 12-1
    # if url: https://scontent.ftpe7-1.fna.fbcdn.net/v/t39.30808-6/491359352_683598494026059_5586019939199564955_n.jpg?stp=cp6_dst-jpegr_tt6&_nc_cat=110&ccb=1-7&_nc_sid=833d8c&_nc_ohc=Tt6CRihAcgsQ7kNvwEnsmr-&_nc_oc=AdnBuN8tcQDp2KNAfflK3715T79FNoRzU7GFsmPrjR9WBMk-2WZOEzewAnymnJqVGDU&_nc_zt=23&se=-1&_nc_ht=scontent.ftpe7-1.fna&_nc_gid=m4DJPgeSD2fyy9JhyP_pVA&oh=00_AfFa0Ych8cad0F-fqYW-NgDddM8hrquzhXc5kE5J1kglzw&oe=6805CAB7
    #  save file into 491359352_683598494026059_5586019939199564955_n.jpg
    if [ 'stp' = "${ARGAN}" -a \
         '_nc_cat' = "${ARGBN}" -a 'ccb' = "${ARGCN}" -a '_nc_sid' = "${ARGDN}" -a '_nc_ohc' = "${ARGEN}" -a \
         '_nc_oc' = "${ARGFN}" -a '_nc_zt' = "${ARGGN}" -a 'se' = "${ARGHN}" -a '_nc_ht' = "${ARGIN}" -a '_nc_gid' = "${ARGJN}" -a \
         'oh' = "${ARGKN}" -a 'oe' = "${ARGLN}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: facebook safeimage
    # if url: https://external.xx.fbcdn.net/safe_image.php?d=AQA9hX2xGLwd2-S0&w=470&h=246&url=fbstaging%3A%2F%2Fgraph.facebook.com%2Fstaging_resources%2FMDExMDczNDY3NDE2MDQ0NzgzOjE5MjY1MTI5NTc%3D&cfs=1&upscale=1&sx=0&sy=51&sw=1034&sh=541
    #

    # fastpic pic
    # if url: http://www.fastpic.jp/images.php?file=4117028328.jpg
    #   save file into 4117028328.jpg(.N)
    if [ 'www.fastpic.jp' = "${HOSTNAME}" -a 'images.php' = "${FILENAME}" -a 'file' = "${ARGAN}" ]; then
        wq_get_filename "${ARGAV}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # giphy pic
    # if url: https://media.giphy.com/media/3o7rbUin16uyk59yec/giphy.gif
    #         https://media.giphy.com/media/SAu2kaYxe3KDK/giphy.mp4
    #   save file into 3o7rbUin16uyk59yec_giphy.gif
    #                  SAu2kaYxe3KDK_giphy.mp4
    if [ 'media.giphy.com' = "${HOSTNAME}" -a 'media' = "${PATHA}" -a 'giphy.gif' = "${FILENAME}" ]; then
        wq_get_filename "${PATHB}_${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # pstatp pic
    # if url: http://p3.pstatp.com/large/92d0004a2a7bce80852
    #   save file into 92d0004a2a7bce80852_large.jpg
    if [ 'pstatp' = "${HOSTNAMEB}" -a 'com' = "${HOSTNAMEC}" ]; then
        wq_get_filename "${FILENAME}_${PATHA}.jpg"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: googleusercontent pic
    # if url: https://lh4.googleusercontent.com/-KdAEFZ8de_U/Vtq0ML9C2nI/AAAAAAAACAA/vQN_HmFaBKg/s0/2016-03-05.jpg
    #   save file into KdAEFZ8de_U_Vtq0ML9C2nI_AAAAAAAACAA_vQN_HmFaBKg_2016-03-05.jpg

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

    # miupix pic
    # if url: http://miupix.cc/di/64XFQ7/uploadFromiPhone.jpg
    #   save file into miupix.cc_di-64XFQ7.jpg(.N)
    if [ 'miupix.cc' = "${HOSTNAME}" ]; then
        wq_get_filename "miupix_${PATHA}_${PATHB}.jpg"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CLEAN_OUTFILE=1
    fi

    # TODO: pchome pic
    # if url: http://a.ecimg.tw/pic/v1/data/item/201312/D/E/A/J/0/Z/DEAJ0Z-A81908181000_52aac5d90bfce
    #                           a   b  c    d    e      f g h i j k
    #   save file into DEAJ0Z-A81908181000_52aac5d90bfce.jpg
    if [ 'ecimg' = "${HOSTNAMEB}" -a 'tw' = "${HOSTNAMEC}" -a 'pic' = "${PATHA}" -a 'data' = "${PATHC}" -a 'item' = "${PATHD}" ]; then
        wq_get_filename "${FILENAME}"

        SET_OUTFILE="-O ${USE_OUTFILE}"
        CHECK_FILETYPE=1
        CLEAN_OUTFILE=1
    fi

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
    CHECKFBS=`${ECHO} "${URL}" | ${GREP} '/[ps][0-9][0-9]*x[0-9][0-9]*/' | ${WC} -l | ${TR} -d ' '`
    if [ ${CHECKFBS} -gt 0 ]; then
        URL=`${ECHO} -n "${URL}" | ${SED} 's/\/[ps][0-9][0-9]*x[0-9][0-9]*\//\//g'`
    fi

    # TODO: taiwanacgn.net pic
    # if url: https://taiwanacgn.net/wp-content/uploads/2015/09/431387eb7262e1cfc79b125eb8a67c60451.jpg
    #   replace url: http://taiwanacgn.net/wp-content/uploads/2015/09/431387eb7262e1cfc79b125eb8a67c60451.jpg

    # TODO: udn pic
    # if url: http://pgw.udn.com.tw/gw/photo.php?u=http://uc.udn.com.tw/photo/2015/10/09/realtime/1392155.jpg
    #   replace url: http://uc.udn.com.tw/photo/2015/10/09/realtime/1392155.jpg


    # check if using curl
    if [ "${OSNAME}" == 'linux' ]; then
      USE_CURL=`${ECHO} "${URL}" | ${GREP} -P "\[[0-9]+-[0-9]+\]" | ${WC} -l | ${TR} -d ' '`
    else
      USE_CURL=`${ECHO} "${URL}" | ${GREP} "\[[0-9]+-[0-9]+\]" | ${WC} -l | ${TR} -d ' '`
    fi

    # get file first
    if [ ${USE_CURL} -gt 0 ]; then
        TMP_FILECOUNT=`${LS} | ${WC} -l | ${TR} -d ' '`
        TMP_DIRNAME=tmp_`${DATE} "+%s"`

        if [ ${TMP_FILECOUNT} -gt 0 ]; then
            ${ECHO} "Bulid tmpdir: ${TMP_DIRNAME}"

            ${MKDIR} -p ${TMP_DIRNAME}
            cd ${TMP_DIRNAME}
        fi

        ${CURL} --insecure --retry 10 -O "${URL}"

        if [ ${TMP_FILECOUNT} -gt 0 ]; then
            ${MV} -in * ../
            cd ..

            ~/work/mirror_script/wq/rmdirdup.sh ${TMP_DIRNAME}

            ${RMDIR} ${TMP_DIRNAME}

            if [ -d "${TMP_DIRNAME}" ]; then
                ${ECHO} "!! DIFF !! DIFF !! DIFF !! DIFF !! DIFF !! DIFF !! DIFF !!"
            fi
        fi

        shift
        continue
    else
        ${WGET} ${SET_OUTFILE} ${WGET_BASE_OPTION} --user-agent="${USE_USER_AGENT}" ${SET_REFERER} "${URL}"
    fi

    # if filesize is 0, remove it
    if [ ! -z "${USE_OUTFILE}" -a -f "${USE_OUTFILE}" -a ! -s "${USE_OUTFILE}" ]; then
        ${RM} "${USE_OUTFILE}"
    fi


    #################################################################
    # TYPE: check file type and rename it                           #
    #################################################################
    if [ ${CHECK_FILETYPE} -gt 0 -a -e "${USE_OUTFILE}" ]; then
        CHECK_OUTFILE=`${FILE} ${USE_OUTFILE}`
        FILETYPE=`${ECHO} "${CHECK_OUTFILE}" | ${AWK} '{printf("%s",$2);}'`
        # filename: GIF image data, version 89a, 360 x 504
        # filename: JPEG image data, JFIF standard 1.01
        # filename: PNG image data, 569 x 790, 8-bit/color RGBA, non-interlaced

        NEW_OUTFILE=''

        if [ 'GIF' = "${FILETYPE}" ]; then
          wq_get_new_filename "${USE_OUTFILE}" 'gif'
        fi

        if [ 'JPEG' = "${FILETYPE}" ]; then
          wq_get_new_filename "${USE_OUTFILE}" 'jpg'
        fi

        if [ 'PNG' = "${FILETYPE}" ]; then
          wq_get_new_filename "${USE_OUTFILE}" 'png'
        fi

        if [ '' != "${NEW_OUTFILE}" ]; then
            ${ECHO} ${MV} "${USE_OUTFILE}" "${NEW_OUTFILE}"
        fi
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
        FILENAME_SIZE=`${ECHO} "${FILENAME}" | ${AWK} -F_ '{printf("%s",$4);}'`
        if [ -z "${FILENAME_SIZE}" ]; then
            # url 3
            FILENAME_BODY=`${ECHO} "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s",$1,$2);}'`
        else
            # url 2
            FILENAME_BODY=`${ECHO} "${FILENAME}" | ${AWK} -F_ '{printf("%s_%s_%s",$1,$2,$3);}'`
        fi

        # try get bigger size: 1280 1024 800 600
        # maybe there are more bigger size in the future
        for MORE_SIZE in 1280 1024 800 600; do
            MORE_URL=`${ECHO} -n "${PROTOCOL}://${HOSTNAME}/${MORE_PATH}${FILENAME_BODY}_${MORE_SIZE}.${FILENAMEEXT}"`

            wq_get_filename "${FILENAME_BODY}_${MORE_SIZE}.${FILENAMEEXT}"

            SET_OUTFILE="-O ${USE_OUTFILE}"
            CLEAN_OUTFILE=1

            ${WGET} ${SET_OUTFILE} ${WGET_BASE_OPTION} --user-agent="${USE_USER_AGENT}" ${SET_REFERER} "${MORE_URL}"

            # if filesize is 0, remove it
            if [ ! -z "${USE_OUTFILE}" -a -f "${USE_OUTFILE}" -a ! -s "${USE_OUTFILE}" ]; then
                ${RM} "${USE_OUTFILE}"

                ${ECHO} "RE-GET ${URL}"
                continue
            fi

            # if get a file, skip smaller size
            if [ -s "${USE_OUTFILE}" ]; then
                break
            fi
        done
    fi

    # TODO: twimg pic
    # if url: https://pbs.twimg.com/media/Cmcj2dRUkAA7udp.jpg
    #   get https://pbs.twimg.com/media/Cmcj2dRUkAA7udp.jpg:orig
    #   compare Cmcj2dRUkAA7udp.jpg and Cmcj2dRUkAA7udp.jpg:large
    #   if same, remove Cmcj2dRUkAA7udp.jpg:orig else remove Cmcj2dRUkAA7udp.jpg

    shift
done


# auto remove duplicate files
if [ ${MKDIR_FIRST} -gt 0 ]; then
    ~/work/mirror_script/wq/rmdirdup.sh ../
    ~/work/mirror_script/wq/rmdotdup.sh

    if [ -d '../../ad9' ]; then
        ~/work/mirror_script/wq/rmdirdup.sh ../../ad9/
    fi

    if [ -d '../../../ad9' ]; then
        ~/work/mirror_script/wq/rmdirdup.sh ../../../ad9/
    fi

    ${ECHO} "file count: `${LS} | ${WC} -l | ${TR} -d ' '`"
fi
