#!/bin/bash
set -e

SOURCE_UNO="${SOURCE_UNO}"
NAME="1️⃣ Uno"
RESULTFILE=uno.conf
TITLE=$(echo -n "${NAME}" | base64)

if ! curl -s --head "$SOURCE_UNO" | head -n 1 | grep -q "HTTP/2 200"; then
    echo "Error: Source is not available"
    exit 1
fi

echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://t.me/gdnavigator" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur" >> $RESULTFILE
curl -s $SOURCE_UNO | \
grep -v '^ss://' | \
grep -v '^vmess://' | \
grep -v '^//' | \
grep -v '^$' | \
awk '{
    if (match($0, /#/)) {
        prefix = substr($0, 1, RSTART-1)
        printf "%s#uno-server-%d\n", prefix, NR
    } else {
        print $0
    }
}' >> $RESULTFILE
