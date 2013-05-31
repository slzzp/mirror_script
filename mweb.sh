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

    if [ 'album.blog.yam.com' == "${HOSTNAME}" ]; then
        # http://album.blog.yam.com/death1121
        HASAND=`echo "${PATHA}" | ${GREP} -- '&' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASAND} -eq 0 ]; then
            if [ -f ~/work/mirror_script/album.blog.yam.com/user.sh ]; then
                ~/work/mirror_script/album.blog.yam.com/user.sh ${URL}
                shift
                continue
            else
                echo 'error: lost script: ~/work/mirror_script/album.blog.yam.com/user.sh'
                exit
            fi
        fi

        # http://album.blog.yam.com/album.php?userid=death1121&page=1&limit=12
        HASUSERID=`echo "${PATHA}" | ${GREP} -- '?userid=' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASUSERID} -gt 0 ]; then
            if [ -f ~/work/mirror_script/album.blog.yam.com/album.sh ]; then
                ~/work/mirror_script/album.blog.yam.com/album.sh ${URL}
                shift
                continue
            else
                echo 'error: lost script: ~/work/mirror_script/album.blog.yam.com/album.sh'
                exit
            fi
        fi

        # http://album.blog.yam.com/death1121&folder=9939631
        HASFOLDER=`echo "${PATHA}" | ${GREP} -- '&folder=' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASFOLDER} -gt 0 ]; then
            if [ -f ~/work/mirror_script/album.blog.yam.com/folder.sh ]; then
                ~/work/mirror_script/album.blog.yam.com/folder.sh ${URL}
                shift
                continue
            else
                echo 'error: lost script: ~/work/mirror_script/album.blog.yam.com/folder.sh'
                exit
            fi
        fi

        # http://album.blog.yam.com/show.php?a=death1121&f=9939631&i=24590367&p=160
        HASSHOW=`echo "${PATHA}" | ${GREP} -- '/show.php?' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASSHOW} -gt 0 ]; then
            if [ -f ~/work/mirror_script/album.blog.yam.com/page.sh ]; then
                ~/work/mirror_script/album.blog.yam.com/page.sh ${URL}
                shift
                continue
            else
                echo 'error: lost script: ~/work/mirror_script/album.blog.yam.com/page.sh'
                exit
            fi
        fi
    fi

    echo "error: unknown url: ${URL}"
    exit
done
