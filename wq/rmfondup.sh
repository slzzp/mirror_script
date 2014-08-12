#!/bin/sh

# external commands
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
FIND="/usr/bin/find"
GREP="/bin/grep"
LS="/bin/ls"
SED="/bin/sed"
TR="/usr/bin/tr"
WC="/usr/bin/wc" 

if [ -z "$1" ]; then
    COMPATH=''
else
    COMPATH=`echo -n "$1"/ | ${SED} 's/\/\/*/\//g'`
fi

# ex: 10454263_299703876868011_6151694217189932071_o.jpg
for F in `${LS} *_o\.*`; do
    FILENAME=`${BASENAME} ${F}`
    FILEKEY=`echo "${FILENAME}" | ${AWK} -F\. '{printf("%s",$1);}' | ${AWK} -F_ '{printf("%s_%s",$2,$3);}'`
    # echo "${FILEKEY}"

    FINDLSA=`${FIND} . -ls | ${GREP} "${FILEKEY}"`
    COUNTFINDLSA=`echo "${FINDLSA}" | ${WC} -l | ${TR} -d ' '`

    if [ ! -z "${COMPATH}" ]; then
        FINDLSB=`${FIND} ${COMPATH} -ls | ${GREP} "${FILEKEY}"`
        COUNTFINDLSB=`echo "${FINDLSB}" | ${WC} -l | ${TR} -d ' '`

        if [ ${COUNTFINDLSA} -gt 0 -a ${COUNTFINDLSB} -gt 0 -a ! -z "${FINDLSB}" ]; then
            echo "${FINDLSA}"
            echo "${FINDLSB}"
            echo ''
        fi
    else
        if [ ${COUNTFINDLSA} -gt 1 ]; then
            echo "${FINDLSA}"
            echo ''
        fi
    fi
done
