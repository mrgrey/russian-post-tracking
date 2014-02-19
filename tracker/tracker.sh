#!/bin/bash
if [[ -z ${1} ]]
then 
  echo "Usage: tracker.sh <tracking number>"; 
  exit 1; 
fi

TRACKING_NUMBER=${1}

#magic post parameters
POST_TRACKER_BASE_URL="http://club.russianpost.ru/com.octopod.russian.post/xml;jsessionid="
VENDOR_ID="FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
APPLICATION_ID=$(( 1000000000000 + ($RANDOM<<20|$RANDOM<<5) ))

MAGIC_POST='{"handlerId":"searchMailing","parameters":{"id":"1","trackingNumber":"'${TRACKING_NUMBER}'","trackingType":"in"},"gmt":"14400","vendorId":"'${VENDOR_ID}'","touch":"1","language":"en","applicationId":"'${APPLICATION_ID}'","platform":"7.0.5","appString":"1|2|0","installationId":"","version":"1.0","client":"iphone","height":"1096","pushToken":"","width":"640","requestType":"serverRequest","files":{},"orientation":"portrait"}'

ANSWER=$( curl --silent \
  -H "Accept-Encoding: gzip" \
  -H "Accept-Language: en-us" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "User-Agent: Russian%20Post/1.1 CFNetwork/672.0.8 Darwin/14.0.0" \
  -d ${MAGIC_POST} \
  ${POST_TRACKER_BASE_URL} )

#echo $ANSWER
echo $ANSWER | egrep -o "VALUES \(.*?\)" \
			 | sed "s/^VALUES (//g" | sed "s/)$//g" | sed "s/NULL/''/g" \
			 | awk '
BEGIN {FS="\x27, \x27"} 
{
	printf "%s @ %s @ %s @ %s @ %s\n", 
	$1, $10, $5, $2, $6
}
' \
			 | sed "s/'//g" | column -s '@' -t