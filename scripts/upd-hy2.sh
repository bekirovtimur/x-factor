#!/bin/bash
set -e
SOURCE_HY2="${SOURCE_HY2}"
NAME="💢 Hysteria2"
RESULTFILE=hy2.conf
TITLE=$(echo -n "${NAME}" | base64)

if ! curl -s --head "$SOURCE_HY2" | head -n 1 | grep -q "HTTP/2 200"; then
    echo "Error: Source is not available"
    exit 1
fi

echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://github.com/bekirovtimur/x-factor/issues" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur/x-factor" >> $RESULTFILE
curl -s $SOURCE_HY2 | \
sed 's/#.*/#🌏 Hysteria2/g' >> $RESULTFILE
