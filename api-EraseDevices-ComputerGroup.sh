#!/bin/bash

# This API script will:
# 1. Look at the membership of a specific Computer Group in Jamf Pro
# 2. For each computer in the Smart Group, push an 'Erase Device' MDM Command
#
# Original for mobile devices Created 5.13.2022 @robjschroeder
# Updated for Computers on 6.20.2022 @dannyl22
#
# Add the Smart Computer Group Group ID variable
# Add the MDM Action, if different than EraseDevice
# https://developer.jamf.com/jamf-pro/reference/computercommands

# API Credentials
username=""
password=""
URL="https://server.jamfcloud.com"

# Smart Device Group ID in Jamf Pro
compDeviceGroupID=""
devicePasscode=""

# MDM Action to be sent
action="EraseDevice"

encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# generate an auth token
authToken=$( /usr/bin/curl "$URL/uapi/auth/tokens" \
--silent \
--request POST \
--header "Authorization: Basic $encodedCredentials" )

# parse authToken for token, omit expiration
token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )

# Get membership details of Computer Device Group
ids+=($(curl --request GET \
--url ${URL}/JSSResource/computergroups/id/${compDeviceGroupID} \
--header 'Accept: application/xml' \
--header "Authorization: Bearer ${token}" | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n))

for id in "${ids[@]}"; do
	if [[ $id -gt 0 ]]; then
		# Post Erase Device command to device
		curl --request POST \
		--url ${URL}/JSSResource/computercommands/command/${action}/passcode/$devicePasscode/id/${id} \
		--header 'Content-Type: application/xml' \
		--header "Authorization: Bearer ${token}"
	else
		echo "Device id ${id} invalid, skipping..."
	fi
done

# Invalidate the token
curl --request POST \
--url ${URL}/api/v1/auth/invalidate-token \
--header 'Accept: application/json' \
--header "Authorization: Bearer ${token}"

exit 0
e