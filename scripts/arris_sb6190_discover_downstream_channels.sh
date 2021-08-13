#1/bin/sh

#MIT License
#
#Copyright (c) 2019 Rob McCready
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.


# Get modem address from command line or default it
modemAddress=$1
if [ -z "$modemAddress" ]; then
  modemAddress=192.168.100.1
fi

username=$2
if [ -z "$username" ]; then
  username=admin
fi

password=$3
if [ -z "$password" ]; then
  password=

#
# Validate dependencies are available
#

if ! [ -x "$(command -v awk)" ]; then
  echo '{"success": 0, "message": "awk command not found"}'
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo '{"success": 0, "message": "curl command not found"}'
  exit 1
fi

if ! [ -x "$(command -v hxnormalize)" ]; then
  echo '{"success": 0, "message": "hxnormalize command not found"}'
  exit 1
fi

#if ! [ -x "$(command -v hxselect)" ]; then
#  echo '{"success": 0, "message": "hxselect command not found"}'
#  exit 1
#fi

if ! [ -x "$(command -v sed)" ]; then
  echo '{"success": 0, "message": "sed command not found"}'
  exit 1
fi

if ! [ -x "$(command -v xmlstarlet)" ]; then
  echo '{"success": 0, "message": "xmlstarlet command not found"}'
  exit 1
fi

if ! [ -x "$(command -v pup)" ]; then
  echo '{"success": 0, "message": "pup command not found"}'
  exit 1
fi



# Some modems use cgi-bin/status other modems use RgConnect.asp
curl --fail -s -o /dev/null http://${modemAddress}/RgConnect.asp >/dev/null 2>&1
retVal=$?
if [ $retVal -ne 0 ]; then
	modemPath="cgi-bin/status_cgi"
else
	modemPath="RgConnect.asp"
fi

# Delete previous cookies file if left behind
rm -f /tmp/arris_sb6190_discover_downstream_channels.cookies

# Only attempt login if user and password given
if [ ! -z "$username" ] && [ ! -z "$password" ]; then
	curl \
	-s \
	-c /tmp/arris_sb6190_discover_downstream_channels.cookies \
	-d "username=$username&password=$password&ar_nonce=87580161" \
	-H "Content-Type: application/x-www-form-urlencoded" \
	-X POST http://$modemAddress/cgi-bin/adv_pwd_cgi >/dev/null 2>&1
fi


# Retrieve status webpage and parse tables into XML
CURL_OUTPUT=$(curl -b /tmp/arris_sb6190_discover_downstream_channels.cookies -s http://$modemAddress/$modemPath 2>/dev/null | hxnormalize -x -d -l 256 2> /dev/null | pup 'table' | sed ':a $!{N; ba}; s|<tbody>|<tbody><th colspan="9">Downstream Bonded Channels</th>|2' | sed 's/ Downstream //g' | sed 's/ kSym\/s//g' | sed 's/ MHz//g' | sed 's/ dBmV//g' | sed 's/ dB//g' | sed 's/<td> */<td>/g' | sed 's/&nbsp;//g')


# Delete cookies file
rm -f /tmp/arris_sb6190_discover_downstream_channels.cookies

STATUS_XML="<tables>$CURL_OUTPUT</tables>"


# Pull out downstream channel data and format INDEX and CHANNEL IDs into discovery format
echo "{"
echo '"data": ['

echo $STATUS_XML | xmlstarlet sel -t -m "//tables/table[2]/tbody/tr[(position() > 1)]" -v "concat('{%{#INDEX}%: %', position()-1, '%, %{#CHANNELID}%: %', td[position()=2], '%},')" -n | sed 's/%/"/g' | sed '$ s/.$//'


echo ']'
echo "}"
