#!/bin/sh

if [ -z "$1" ]; then
    exit
fi


# if show debug message, set to 1, else set to 0
DEBUGMSG=0


# external commands
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CUT="/usr/bin/cut"
EXPR="/usr/bin/expr"


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
HOSTNAMEE=`echo "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$5);}'`

PATHA=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$4);}'`
PATHB=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$5);}'`
PATHC=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$6);}'`
PATHD=`echo "${URL}" | ${AWK} -F/ '{printf("%s",$7);}'`

FILENAMEARG=`${BASENAME} "${URL}"`
FILENAME=`echo "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$1);}'`
FILENAMEEXT=`echo "${FILENAME}" | ${AWK} -F. '{printf("%s", $NF);}'`

FILENAMELEN=${#FILENAME}
FILENAMEEXTLEN=${#FILENAMEEXT}
FILENAMEMAINLEN=`${EXPR} ${FILENAMELEN} - ${FILENAMEEXTLEN} - 1`

FILENAMEMAIN=`echo "${FILENAME}" | ${CUT} -c 1-${FILENAMEMAINLEN}`

FILENAMEMAINFBA=`echo "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$1);}'`
FILENAMEMAINFBB=`echo "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$2);}'`
FILENAMEMAINFBC=`echo "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$3);}'`
FILENAMEMAINFBD=`echo "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$4);}'`

ARGS=`echo "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$2);}'`

ARGA=`echo "${ARGS}" | ${AWK} -F\& '{printf("%s",$1);}'`
ARGAN=`echo "${ARGA}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGAV=`echo "${ARGA}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGB=`echo "${ARGS}" | ${AWK} -F\& '{printf("%s",$2);}'`
ARGBN=`echo "${ARGB}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGBV=`echo "${ARGB}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGC=`echo "${ARGS}" | ${AWK} -F\& '{printf("%s",$3);}'`
ARGCN=`echo "${ARGC}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGCV=`echo "${ARGC}" | ${AWK} -F= '{printf("%s",$2);}'`


# debug output
if [ ${DEBUGMSG} -gt 0 ]; then
    echo "URL='${URL}'"
    echo "PROTOCOL='${PROTOCOL}'"

    echo "HOSTNAME='${HOSTNAME}'"
    echo "HOSTNAMEA='${HOSTNAMEA}'"
    echo "HOSTNAMEB='${HOSTNAMEB}'"
    echo "HOSTNAMEC='${HOSTNAMEC}'"
    echo "HOSTNAMED='${HOSTNAMED}'"
    echo "HOSTNAMEE='${HOSTNAMEE}'"

    echo "PATHA='${PATHA}'"
    echo "PATHB='${PATHB}'"
    echo "PATHC='${PATHC}'"
    echo "PATHD='${PATHD}'"

    echo "FILENAMEARG='${FILENAMEARG}'"
    echo "FILENAME='${FILENAME}'"
    echo "FILENAMEMAIN='${FILENAMEMAIN}'"
    echo "FILENAMEEXT='${FILENAMEEXT}'"

    echo "FILENAMEMAINFBA='${FILENAMEMAINFBA}'"
    echo "FILENAMEMAINFBB='${FILENAMEMAINFBB}'"
    echo "FILENAMEMAINFBC='${FILENAMEMAINFBC}'"
    echo "FILENAMEMAINFBD='${FILENAMEMAINFBD}'"

    echo "ARGS='${ARGS}'"
    echo "ARGA='${ARGA}'"
    echo "ARGAN='${ARGAN}'"
    echo "ARGAV='${ARGAV}'"
    echo "ARGB='${ARGB}'"
    echo "ARGBN='${ARGBN}'"
    echo "ARGBV='${ARGBV}'"
    echo "ARGC='${ARGC}'"
    echo "ARGCN='${ARGCN}'"
    echo "ARGCV='${ARGCV}'"
fi
