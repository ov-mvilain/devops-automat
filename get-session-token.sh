##! /usr/bin/env bash
# 202201.04MeV create temporary AWS credentials

# https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
# for full information on temporary credentials and sts

SCRIPT=$(basename $0)
OPT_D=""		# false
OPT_N=""
OPT_V=""
OPT_T=$(expr 60 \* 15)		# default 15m
TEMP_1=
UNSET="/tmp/${SCRIPT}-unset"
EXPORT="/tmp/${SCRIPT}-export"
MFA=""

cat <<UNSET > ${UNSET}
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY # aws cli
	unset AWS_SESSION_TOKEN
	unset AWS_SESSION_EXPIRE
	unset AWS_ACCESS_KEY AWS_SECRET_KEY   # terraform
UNSET

usage () {
	cat <<USAGE

${SCRIPT} -h -v [-t <session-in-seconds>] | <MFA>

	run a disk audit using swift-recon on HOST with an optional USER
	This script requires expect and an ssh tunnel to the host or
	list of hosts prior to running the script.

	OPTIONS
	MFA          Multi-factor authentication token
	-h           display this help text and exit
	-t           session duration in seconds (min:900=15m max:129600=36h [default: 15m])
	-v           output AWS credentials
	NOTE: root MFA account have a max session time of 3600 (1h)

USAGE
}

trap aborted INT # trap ctrl-c and call ctrl_c()

function aborted() {
	echo "${SCRIPT} -- aborted"
	rm -rf ${TEMP_1} ${AWK_PROG}
	exit 2
}

while getopts ":dhut:v" OPT; do
	case $OPT in
	h)
		usage
		exit 0
		;;
	t)
		OPT_T=${OPTARG}		# don't bother validating it's a number...let aws barf
		;;
	u)
		# unset variables and exit
		echo "source ${UNSET} ...to unset session variables"
		[[ ! $OPT_V ]] && cat ${UNSET}
		exit 0
		;;
	v)
		OPT_V=1  # true
		;;
	esac
done
# shift points arg list to 1st non-argument
shift $((OPTIND-1))
MFA=$1

if [[ "${MFA}" == "" ]]; then
	echo "${SCRIPT} -- MFA missing"
	exit 1
fi
TEMP_1=$(mktemp /tmp/${SCRIPT}.XXXXXX)
AWK_PROG=$(mktemp /tmp/${SCRIPT}.awk.XXXXXX)


arn=$(aws sts get-caller-identity | awk '
	/Arn/ { gsub("\"","",$1); gsub(":","",$1);
	        gsub(",", "",$2); gsub("\"","",$2); gsub("user", "mfa",$2);
	        print $2 }
	')
[[ ${OPT_V} ]] && echo ${arn}

source ${UNSET}		# ensure any old credentials are removed
# output the session variables to EXPORT file
# aws sts get-session-token --serial-number xxx --duration-seconds yyy --token-code nnnnnn
aws sts get-session-token --serial-number ${arn} \
		--duration-seconds ${OPT_T} \
		--token-code ${MFA} > ${TEMP_1}
if [[ $? -ne 0 ]]; then
	# aws sts outputs error messages directly to terminal regardless of redirection
	cat ${TEMP_1}
	aborted
fi
cat << "PROG" > ${AWK_PROG}
	/AccessKeyId|SecretAccessKey|SessionToken|Expiration/{
		gsub(":","",$1); gsub("\"","",$1);
		sub("AccessKeyId", "AWS_ACCESS_KEY_ID", $1)
		sub("SecretAccessKey", "AWS_SECRET_ACCESS_KEY", $1)
		sub("SessionToken", "AWS_SESSION_TOKEN", $1)
		sub("Expiration", "AWS_SESSION_EXPIRE", $1)
		gsub(",", "",$2);
		print "export", $1 "=" $2
	}
PROG
awk '/AccessKeyId|SecretAccessKey|SessionToken|Expiration/{
		gsub(":","",$1); gsub("\"","",$1);
		sub("AccessKeyId", "AWS_ACCESS_KEY_ID", $1)
		sub("SecretAccessKey", "AWS_SECRET_ACCESS_KEY", $1)
		sub("SessionToken", "AWS_SESSION_TOKEN", $1)
		sub("Expiration", "AWS_SESSION_EXPIRE", $1)
		gsub(",", "",$2);
		print "export", $1 "=" $2
	}
' ${TEMP_1} > ${EXPORT}
[[ $? -ne 0 ]] && cat ${AWK_PROG} ${TEMP_1} ${EXPORT}
source ${EXPORT}

if [[ ${OPT_V} ]]; then
	cat ${EXPORT}
	cat ${UNSET}
else
	echo "source ${EXPORT} ...to set session variables expiring ${AWS_SESSION_EXPIRE}"
	echo "source ${UNSET} ...to unset session variables"
fi

rm -rf ${TEMP_1} ${AWK_PROG}
exit 0
