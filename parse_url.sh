#!/bin/sh

if [ -z "$1" ]; then
    exit
fi


# if show debug message, set to 1, else set to 0
DEBUGMSG=0


# external commands
. ~/work/mirror_script/cmd.sh

# preprocess url
URL=`${ECHO} -n "$1"`

# check if $1's prefix is '//'
CHECKSLASHSLASH=`${ECHO} "$1" | ${CUT} -c 1-2`
if [ "//" = "${CHECKSLASHSLASH}" ]; then
    URL=`${ECHO} -n "http:$1"`
fi


# URL decode first for parse
#   %26 -> &
#   %2F -> /
#   %3D -> =
#   %3F -> ?
PARSEURL=`${ECHO} -n "${URL}" | ${SED} 's/%26/\&/g' | ${SED} 's/%2F/\//g' | ${SED} 's/%3D/\=/g' | ${SED} 's/%3F/\?/g'`

# parse url
PROTOCOL=`${ECHO} "${PARSEURL}" | ${AWK} -F: '{printf("%s",$1);}'`

HOSTNAME=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$3);}'`

HOSTNAMEA=`${ECHO} "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$1);}'`
HOSTNAMEB=`${ECHO} "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$2);}'`
HOSTNAMEC=`${ECHO} "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$3);}'`
HOSTNAMED=`${ECHO} "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$4);}'`
HOSTNAMEE=`${ECHO} "${HOSTNAME}" | ${AWK} -F. '{printf("%s",$5);}'`

PATHA=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$4);}'`
PATHB=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$5);}'`
PATHC=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$6);}'`
PATHD=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$7);}'`
PATHE=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$8);}'`
PATHF=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$9);}'`
PATHG=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$10);}'`
PATHH=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$11);}'`
PATHI=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$12);}'`
PATHJ=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$13);}'`
PATHK=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$14);}'`
PATHL=`${ECHO} "${PARSEURL}" | ${AWK} -F/ '{printf("%s",$15);}'`

FILENAMEARG=`${BASENAME} "${PARSEURL}"`
FILENAME=`${ECHO} "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$1);}'`
FILENAMEEXT=`${ECHO} "${FILENAME}" | ${AWK} -F. '{printf("%s", $NF);}'`

if [ "${FILENAME}" = "${FILENAMEEXT}" ]; then
  FILENAMEEXT=''
fi

FILENAMELEN=${#FILENAME}
FILENAMEEXTLEN=${#FILENAMEEXT}
FILENAMEMAINLEN=`${EXPR} ${FILENAMELEN} - ${FILENAMEEXTLEN} - 1`

if [ ${FILENAMEEXTLEN} -gt 0 ]; then
  FILENAMEMAIN=`${ECHO} "${FILENAME}" | ${CUT} -c 1-${FILENAMEMAINLEN}`
else
  FILENAMEMAIN=`${ECHO} -n "${FILENAME}"`
fi

FILENAMEMAINFBA=`${ECHO} "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$1);}'`
FILENAMEMAINFBB=`${ECHO} "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$2);}'`
FILENAMEMAINFBC=`${ECHO} "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$3);}'`
FILENAMEMAINFBD=`${ECHO} "${FILENAMEMAIN}" | ${AWK} -F_ '{printf("%s",$4);}'`

ARGS=`${ECHO} "${FILENAMEARG}" | ${AWK} -F? '{printf("%s",$2);}'`

ARGA=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$1);}'`
ARGAN=`${ECHO} "${ARGA}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGAV=`${ECHO} "${ARGA}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGB=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$2);}'`
ARGBN=`${ECHO} "${ARGB}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGBV=`${ECHO} "${ARGB}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGC=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$3);}'`
ARGCN=`${ECHO} "${ARGC}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGCV=`${ECHO} "${ARGC}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGD=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$4);}'`
ARGDN=`${ECHO} "${ARGD}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGDV=`${ECHO} "${ARGD}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGE=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$5);}'`
ARGEN=`${ECHO} "${ARGE}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGEV=`${ECHO} "${ARGE}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGF=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$6);}'`
ARGFN=`${ECHO} "${ARGF}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGFV=`${ECHO} "${ARGF}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGG=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$7);}'`
ARGGN=`${ECHO} "${ARGG}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGGV=`${ECHO} "${ARGG}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGH=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$8);}'`
ARGHN=`${ECHO} "${ARGH}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGHV=`${ECHO} "${ARGH}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGI=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$9);}'`
ARGIN=`${ECHO} "${ARGI}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGIV=`${ECHO} "${ARGI}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGJ=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$10);}'`
ARGJN=`${ECHO} "${ARGJ}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGJV=`${ECHO} "${ARGJ}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGK=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$11);}'`
ARGKN=`${ECHO} "${ARGK}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGKV=`${ECHO} "${ARGK}" | ${AWK} -F= '{printf("%s",$2);}'`

ARGL=`${ECHO} "${ARGS}" | ${AWK} -F\& '{printf("%s",$12);}'`
ARGLN=`${ECHO} "${ARGL}" | ${AWK} -F= '{printf("%s",$1);}'`
ARGLV=`${ECHO} "${ARGL}" | ${AWK} -F= '{printf("%s",$2);}'`


# debug output
if [ ${DEBUGMSG} -gt 0 ]; then
    ${ECHO} "URL='${URL}'"
    ${ECHO} "PROTOCOL='${PROTOCOL}'"

    ${ECHO} "HOSTNAME='${HOSTNAME}'"
    ${ECHO} "HOSTNAMEA='${HOSTNAMEA}'"
    ${ECHO} "HOSTNAMEB='${HOSTNAMEB}'"
    ${ECHO} "HOSTNAMEC='${HOSTNAMEC}'"
    ${ECHO} "HOSTNAMED='${HOSTNAMED}'"
    ${ECHO} "HOSTNAMEE='${HOSTNAMEE}'"

    ${ECHO} "PATHA='${PATHA}'"
    ${ECHO} "PATHB='${PATHB}'"
    ${ECHO} "PATHC='${PATHC}'"
    ${ECHO} "PATHD='${PATHD}'"
    ${ECHO} "PATHE='${PATHE}'"
    ${ECHO} "PATHF='${PATHF}'"
    ${ECHO} "PATHG='${PATHG}'"
    ${ECHO} "PATHH='${PATHH}'"
    ${ECHO} "PATHI='${PATHI}'"
    ${ECHO} "PATHJ='${PATHJ}'"
    ${ECHO} "PATHK='${PATHK}'"
    ${ECHO} "PATHL='${PATHL}'"

    ${ECHO} "FILENAMEARG='${FILENAMEARG}'"
    ${ECHO} "FILENAME='${FILENAME}'"
    ${ECHO} "FILENAMEMAIN='${FILENAMEMAIN}'"
    ${ECHO} "FILENAMEEXT='${FILENAMEEXT}'"

    ${ECHO} "FILENAMEMAINFBA='${FILENAMEMAINFBA}'"
    ${ECHO} "FILENAMEMAINFBB='${FILENAMEMAINFBB}'"
    ${ECHO} "FILENAMEMAINFBC='${FILENAMEMAINFBC}'"
    ${ECHO} "FILENAMEMAINFBD='${FILENAMEMAINFBD}'"

    ${ECHO} "ARGS='${ARGS}'"
    ${ECHO} "ARGA='${ARGA}'"
    ${ECHO} "ARGAN='${ARGAN}'"
    ${ECHO} "ARGAV='${ARGAV}'"
    ${ECHO} "ARGB='${ARGB}'"
    ${ECHO} "ARGBN='${ARGBN}'"
    ${ECHO} "ARGBV='${ARGBV}'"
    ${ECHO} "ARGC='${ARGC}'"
    ${ECHO} "ARGCN='${ARGCN}'"
    ${ECHO} "ARGCV='${ARGCV}'"
    ${ECHO} "ARGD='${ARGD}'"
    ${ECHO} "ARGDN='${ARGDN}'"
    ${ECHO} "ARGDV='${ARGDV}'"
    ${ECHO} "ARGE='${ARGE}'"
    ${ECHO} "ARGEN='${ARGEN}'"
    ${ECHO} "ARGEV='${ARGEV}'"
    ${ECHO} "ARGF='${ARGF}'"
    ${ECHO} "ARGFN='${ARGFN}'"
    ${ECHO} "ARGFV='${ARGFV}'"
    ${ECHO} "ARGG='${ARGG}'"
    ${ECHO} "ARGGN='${ARGGN}'"
    ${ECHO} "ARGGV='${ARGGV}'"
    ${ECHO} "ARGH='${ARGH}'"
    ${ECHO} "ARGHN='${ARGHN}'"
    ${ECHO} "ARGHV='${ARGHV}'"
    ${ECHO} "ARGI='${ARGI}'"
    ${ECHO} "ARGIN='${ARGIN}'"
    ${ECHO} "ARGIV='${ARGIV}'"
    ${ECHO} "ARGJ='${ARGJ}'"
    ${ECHO} "ARGJN='${ARGJN}'"
    ${ECHO} "ARGJV='${ARGJV}'"
    ${ECHO} "ARGK='${ARGK}'"
    ${ECHO} "ARGKN='${ARGKN}'"
    ${ECHO} "ARGKV='${ARGKV}'"
    ${ECHO} "ARGL='${ARGL}'"
    ${ECHO} "ARGLN='${ARGLN}'"
    ${ECHO} "ARGLV='${ARGLV}'"
fi
