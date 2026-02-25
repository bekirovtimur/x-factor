#!/bin/bash
set -e

SOURCE_X="${SOURCE_X}"
NAME="𝕏-Factor"
RESULTFILE=proxy.conf
TITLE=$(echo -n "${NAME}" | base64)

if ! curl -s --head "$SOURCE_X" | head -n 1 | grep -q "HTTP/2 200"; then
    echo "Error: source is not available"
    exit 1
fi

echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://github.com/bekirovtimur/x-factor/issues" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur" >> $RESULTFILE
curl -s $SOURCE_X | \
grep -v '^ss://' | \
grep -v '^//' | \
grep -v '^$' >> $RESULTFILE
