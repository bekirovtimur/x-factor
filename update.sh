#!/bin/bash
SOURCE="https://raw.githubusercontent.com/4n0nymou3/multi-proxy-config-fetcher/refs/heads/main/configs/proxy_configs.txt"
NAME="𝕏-Factor"
RESULTFILE=proxy.conf
TITLE=$(echo -n "${NAME}" | base64)
echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://t.me/gdnavigator" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur" >> $RESULTFILE
curl -s $SOURCE | \
grep -v '^ss://' | \
grep -v '^//' | \
grep -v '^$' >> $RESULTFILE
