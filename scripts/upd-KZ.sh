#!/bin/bash
# set -e
SOURCE_TRES="${SOURCE_TRES}"
SOURCE_COLLECTOR="${SOURCE_COLLECTOR}"
NAME="🇰🇿 Kazakhstan"
COUNTRY_CODE="KZ"
COUNTRY_FLAG="🇰🇿"
RESULTFILE=KZ.conf
TITLE=$(echo -n "${NAME}" | base64)

sources=("$SOURCE_TRES" "$SOURCE_COLLECTOR")
available_count=0

# Функция для резолва доменного имени в IP
resolve_domain() {
    local host="$1"
    # Проверяем, является ли это уже IP адресом
    if [[ $host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$host"
        return
    fi
    
    # Резолвим доменное имя
    local ip=$(dig +short "$host" | head -n1)
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
    else
        echo ""
    fi
}

# Функция для получения информации об IP
get_ip_info() {
    local ip="$1"
    local response=$(curl -s "http://ip-api.com/json/$ip")
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response"
    else
        echo ""
    fi
}

# Функция для извлечения IP/домена из VLESS URL
extract_host_from_url() {
    local url="$1"
    # Извлекаем часть между @ и : (только хост, без параметров)
    echo "$url" | sed -E 's/.*@([^:]+):[0-9]+.*/\1/'
}

# Функция для генерации имени сервера
generate_server_name() {
    local ip_info="$1"
    
    # Извлекаем данные из JSON
    local country_code=$(echo "$ip_info" | jq -r '.countryCode // empty')
    local city=$(echo "$ip_info" | jq -r '.city // empty')
    local isp=$(echo "$ip_info" | jq -r '.isp // empty')
    
    # Проверяем соответствие countryCode
    if [ "$country_code" != "$COUNTRY_CODE" ]; then
        return 1
    fi
    
    # Формируем имя сервера с обычными пробелами
    local server_name="${COUNTRY_FLAG}"
    
    if [ -n "$city" ] && [ "$city" != "null" ]; then
        server_name="${server_name} ${city}"
    fi
    
    if [ -n "$isp" ] && [ "$isp" != "null" ]; then
        server_name="${server_name} ${isp}"
    fi
    
    server_name="${server_name} ${country_code}"
    
    # Заменяем ВСЕ пробелы на %20 в самом конце
    server_name=$(echo "$server_name" | sed 's/ /%20/g')
    
    echo "$server_name"
    return 0
}

# Проверяем доступность источников
for source in "${sources[@]}"; do
    if curl -s --head "$source" | head -n 1 | grep -q "HTTP/2 200"; then
        ((available_count++))
    fi
done

if [ $available_count -eq 0 ]; then
    echo "Error: All sources are not available"
    exit 1
fi

# Создаем заголовок файла
echo -n > $RESULTFILE
echo "//profile-title: base64:${TITLE}" >> $RESULTFILE
echo "//profile-update-interval: 1" >> $RESULTFILE
echo "//subscription-userinfo: upload=0; download=0; total=10737418240000000; expire=2546249531" >> $RESULTFILE
echo "//support-url: https://github.com/bekirovtimur/x-factor/issues" >> $RESULTFILE
echo "//profile-web-page-url: https://github.com/bekirovtimur" >> $RESULTFILE

echo -n > all_sources.tmp

# Загружаем данные из источников
for source in "${sources[@]}"; do
    if curl -s --head "$source" | head -n 1 | grep -q "HTTP/2 200"; then
        curl -s "$source" | \
        grep -E '^vless://' | \
        grep -E "#($COUNTRY_CODE|$COUNTRY_FLAG)" >> all_sources.tmp
    fi
done

# Обрабатываем каждую строку
cat all_sources.tmp | \
sort | \
uniq | \
while IFS= read -r line; do
    if [ -z "$line" ]; then
        continue
    fi
    
    # Извлекаем хост из URL
    host=$(extract_host_from_url "$line")
    
    if [ -z "$host" ]; then
        continue
    fi
    
    # Резолвим в IP если это домен
    ip=$(resolve_domain "$host")
    
    if [ -z "$ip" ]; then
        echo "Warning: Could not resolve $host" >&2
        continue
    fi
    
    # Получаем информацию об IP
    ip_info=$(get_ip_info "$ip")
    
    if [ -z "$ip_info" ]; then
        echo "Warning: Could not get info for IP $ip" >&2
        continue
    fi
    
    # Добавляем задержку между запросами к ip-api.com (лимит: 45 запросов/минуту)
    sleep 1.4

    # Генерируем имя сервера
    server_name=$(generate_server_name "$ip_info")
    
    if [ $? -eq 0 ] && [ -n "$server_name" ]; then
        # Устанавливаем имена для серверов
        new_line=$(echo "$line" | sed -E 's/#.*$//' | sed -E "s/$/#${server_name}/")
        echo "$new_line"
    else
        echo "Info: Skipping server with IP $ip (country code mismatch or missing data)" >&2
    fi
done >> $RESULTFILE

rm all_sources.tmp

echo "Processing completed. Result saved to $RESULTFILE"
