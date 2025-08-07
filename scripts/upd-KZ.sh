#!/bin/bash
# set -e
SOURCE_TRES="${SOURCE_TRES}"
SOURCE_COLLECTOR="${SOURCE_COLLECTOR}"
NAME="🇰🇿 Kazakhstan"
RESULTFILE=KZ.conf
TITLE=$(echo -n "${NAME}" | base64)

sources=("$SOURCE_TRES" "$SOURCE_COLLECTOR")
available_count=0

for source in "${sources[@]}"; do
    if curl -s --head "$source" | head -n 1 | grep -q "HTTP/2 200"; then
        ((available_count++))
    fi
done
if [ $available_count -eq 0 ]; then
    echo "Error: All sources are not available"
    exit 1
fi

echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://t.me/gdnavigator" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur" >> $RESULTFILE

echo -n > all_sources.tmp

for source in "${sources[@]}"; do
    if curl -s --head "$source" | head -n 1 | grep -q "HTTP/2 200"; then
        curl -s "$source" | \
        grep -E '#(🇰🇿|KZ)' |
        sed -E 's/#.*//' >> all_sources.tmp
    fi
done

cat all_sources.tmp | \
sort | \
uniq | \
  while IFS= read -r line; do
    name=$(petname)
    new_line=$(echo "$line" | sed -E "s/$/#🇰🇿-$name-KZ/")
    echo "$new_line"
  done >> $RESULTFILE
rm all_sources.tmp
