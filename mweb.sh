#!/bin/sh

# $0 url [url2 [url3 [...]]]
if [ -z "$1" ]; then
    exit;
fi


# external commands
AWK="/usr/bin/awk"
CUT="/usr/bin/cut"
EXPR="/usr/bin/expr"
GREP="/bin/grep"
MKDIR="/bin/mkdir"
RMDIR="/bin/rmdir"
TR="/usr/bin/tr"
WC="/usr/bin/wc"


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


while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "$0" = "$1" ]; then
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
    . ~/work/mirror_script/parse_url.sh "${URL}"


    # check url
    if [ 'album.blog.yam.com' = "${HOSTNAME}" ]; then
        # http://album.blog.yam.com/death1121
#        wq_string_has_char "${URL}" '@'
#        if [ "$?" -gt 0 ]; then

        HASAND=`echo "${PATHA}" | ${GREP} -- '&' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASAND} -eq 0 ]; then
            WORKER=~/work/mirror_script/album.blog.yam.com/user.sh

            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi

        # http://album.blog.yam.com/album.php?userid=death1121&page=1&limit=12
        HASUSERID=`echo "${PATHA}" | ${GREP} -- '?userid=' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASUSERID} -gt 0 ]; then
            WORKER=~/work/mirror_script/album.blog.yam.com/album.sh

            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi

        # http://album.blog.yam.com/death1121&folder=9939631
        HASFOLDER=`echo "${PATHA}" | ${GREP} -- '&folder=' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASFOLDER} -gt 0 ]; then
            WORKER=~/work/mirror_script/album.blog.yam.com/folder.sh

            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi

        # http://album.blog.yam.com/show.php?a=death1121&f=9939631&i=24590367&p=160
        HASSHOW=`echo "${PATHA}" | ${GREP} -- '/show.php?' | ${WC} -l | ${TR} -d ' '`
        if [ ${HASSHOW} -gt 0 ]; then
            WORKER=~/work/mirror_script/album.blog.yam.com/page.sh

            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi
    fi

    # if http://www.huanjue.net/show.php?aid=4082&page=73
    # call wq -d 4627 'https://shengyijun.net/huanjue/5/4082/[001-074].jpg'
    #                 'https://shengyijun.cc/huanjue/5/4082/[001-074].jpg'
    # notice: N000 rule
    # if http://www.huanjue.net/show.php?aid=4000&page=47
    # call wq -d 4000 'https://shengyijun.net/huanjue/4/4000/[001-048].jpg'
    if [ 'www.huanjue.net' = "${HOSTNAME}" -a 'show.php' = "${FILENAME}" ]; then
        ${MKDIR} -p ~/tmp/stockings/huanjue.net
        cd ~/tmp/stockings/huanjue.net

        if [ 'aid' = "${ARGAN}" -a 'page' = "${ARGBN}" ]; then
            if [ 0 -eq `${EXPR} ${ARGAV} % 1000` ]; then
                HUANJUEINDEX=`${EXPR} ${ARGAV} / 1000`
            else
                HUANJUEINDEX=`${EXPR} ${ARGAV} / 1000 + 1 `
            fi

            WQURL="https://shengyijun.net/huanjue/${HUANJUEINDEX}/${ARGAV}/[001-`${EXPR} ${ARGBV} + 1`].jpg"
#            WQURL="https://shengyijun.cc/huanjue/${HUANJUEINDEX}/${ARGAV}/[001-`${EXPR} ${ARGBV} + 1`].jpg"

            if [ ! -d "${ARGAV}" ]; then
              ~/work/mirror_script/wq/wq.sh -d "${ARGAV}" ${WQURL}

              if [ -d "${ARGAV}no" ]; then
                ${RMDIR} "${ARGAV}no"
              fi
            fi
        fi

        if [ 'aid' = "${ARGBN}" -a 'page' = "${ARGAN}" ]; then
            if [ 0 -eq `${EXPR} ${ARGBV} % 1000` ]; then
                HUANJUEINDEX=`${EXPR} ${ARGBV} / 1000`
            else
                HUANJUEINDEX=`${EXPR} ${ARGBV} / 1000 + 1 `
            fi

            WQURL="https://shengyijun.net/huanjue/${HUANJUEINDEX}/${ARGBV}/[001-`${EXPR} ${ARGAV} + 1`].jpg"
#            WQURL="https://shengyijun.cc/huanjue/${HUANJUEINDEX}/${ARGBV}/[001-`${EXPR} ${ARGAV} + 1`].jpg"

            if [ ! -d "${ARGBV}" ]; then
              ~/work/mirror_script/wq/wq.sh -d "${ARGBV}" ${WQURL}

              if [ -d "${ARGBV}no" ]; then
                ${RMDIR} "${ARGBV}no"
              fi
            fi
        fi

        echo ${URL}
        exit
    fi

    # if https://shengyijun.net/masheng/11/10465/032.jpg
    #   from https://www.masheng.net/article-10465-11/
    # call wq -d 10465 'https://shengyijun.net/masheng/11/10465/[001-032].jpg'
    #                  'https://shengyijun.cc/masheng/11/10465/[001-032].jpg'
    # notice: N000 rule
    # if https://shengyijun.net/masheng/10/10000/040.jpg
    # call wq -d 10000 'https://shengyijun.net/masheng/10/10000/[001-040].jpg'
    if [ 'shengyijun.net' = "${HOSTNAME}" -a 'masheng' = "${PATHA}" ]; then
        ${MKDIR} -p ~/tmp/stockings/masheng.net
        cd ~/tmp/stockings/masheng.net

        if [ 0 -eq `${EXPR} ${PATHC} % 1000` ]; then
            HUANJUEINDEX=`${EXPR} ${PATHC} / 1000`
        else
            HUANJUEINDEX=`${EXPR} ${PATHC} / 1000 + 1 `
        fi

        WQURL="https://shengyijun.net/masheng/${HUANJUEINDEX}/${PATHC}/[001-${FILENAMEMAIN}].jpg"

        if [ ! -d "${PATHC}" ]; then
          ~/work/mirror_script/wq/wq.sh -d "${PATHC}" ${WQURL}

          if [ -d "${PATHC}no" ]; then
            ${RMDIR} "${PATHC}no"
          fi
        fi

        echo ${URL}
        exit
    fi

    if [ 'blog.livedoor.jp' = "${HOSTNAME}" ]; then
        # http://blog.livedoor.jp/pinkelech/archives/25313738.html
        if [ 'archives' = "${PATHB}" ]; then
            WORKER=~/work/mirror_script/blog.livedoor.jp/archives.sh

            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi
    fi

    if [ 'fc2' = "${HOSTNAMEC}" -a 'com' = "${HOSTNAMED}" ]; then
        # http://sanzierogazo.blog129.fc2.com/blog-entry-2564.html
        HOSTNAMEBB=`echo "${HOSTNAMEB}" | ${CUT} -c 1-4`
        if [ 'blog' = "${HOSTNAMEBB}" ]; then
            WORKER=~/work/mirror_script/blog.fc2.com/blog_entry.sh
            if [ ! -z "${WORKER}" -a -f "${WORKER}" ]; then
                ${WORKER} ${URL}

                shift
                continue
            else
                echo "Error: lost script: ${WORKER}"
                exit
            fi
        fi
    fi

    echo "Error: unknown url: ${URL}"
    exit
done
