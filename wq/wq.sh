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
WGET="/usr/bin/wget"

while [ ! -z "$1" ]; do
    # avoid double-typed command
    if [ "wq" == "$1" -o "wq.sh" == "$1" -o "$0" == "$1" ]; then
        shift
        continue
    fi

    # -4: some site has ipv6 address, but no route of ipv6, so force using ipv4 only
    # --no-check-certificate: do not check ssl/cert for https:// url
    ${WGET} -nv -4 --no-check-certificate "$1"

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

            ${WGET} -4 -nv --no-check-certificate "${URL}"

            # if get a file, skip smaller size
            if [ -f "${LOCALFILENAME}" ]; then
                break
            fi
        done
    fi

    shift
done
