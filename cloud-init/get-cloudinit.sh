#!/bin/bash
UBUNTU="focal"
FILE="${UBUNTU}-server-cloudimg-amd64.ova"
RSUM=`curl -SsL https://cloud-images.ubuntu.com/${UBUNTU}/current/MD5SUMS | grep $FILE | cut -d" " -f1`
LSUM="00000000000000000000000000000000"

[[ -e "./${FILE}" ]] && {
    LSUM=`md5sum ${FILE} | cut -d" " -f1`
}

[[ "$LSUM" == "$RSUM" ]] && {
    echo "You already have the latest ova."
    exit 0
}

[[ -e "./${FILE}" ]] && {
    echo "Found old ${FILE}"
    mv -v ${FILE} ${FILE}.backup
}

curl -SsLO "https://cloud-images.ubuntu.com/${UBUNTU}/current/${FILE}"

LSUM=`md5sum $FILE | cut -d" " -f1`
[[ "$LSUM" == "$RSUM" ]] && {
    echo "You now have the latest ova."
    exit 0
}
