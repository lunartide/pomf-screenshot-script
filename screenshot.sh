#!/bin/bash

retries=1 # number of times to retry (per host) if the upload fails

host_upload_urls[0]='http://pomf.cat/upload.php' # the url of the pomf upload script
host_content_urls[0]='http://a.pomf.cat' # the url where images are stored on the host

echo "drag to select area"

scrot_response="$(scrot -s /tmp/screenshot.png &>/dev/null)" # scrot -s takes a screenshot from selection

if [ "${?}" != "0" ]; then
  xmessage -nearmouse -buttons "" -timeout 3 "failed to take screenshot"
  exit 1
fi

echo "uploading..."

i=0
while [[ $i -le ${#host_upload_urls[@]} ]]; do
  host_upload_url=${host_upload_urls[i]}
  host_content_url=${host_content_urls[i]}

  try=0
  while [[ $try -le $retries ]]; do
    curl_response=$(curl --silent -sf -F files[]="@/tmp/screenshot.png" "${host_upload_url}")
  	if [[ "${curl_response}" =~ '"success":true,' ]]; then
  		return_file=$(echo "$curl_response" | grep -Eo '"url":"[A-Za-z0-9]+.png",' | sed 's/"url":"//;s/",//')
  		break
  	else
      echo "upload to ${host_upload_url} failed, retrying"
  		((n = n+1))
  	fi
  done

  if [[ -n ${return_file} ]]; then
    echo "upload complete: ${host_content_url}/${return_file}"
    xmessage -nearmouse -buttons "" -timeout 2 "upload complete"
    echo -n "${host_content_url}/${return_file}" | xclip -selection clipboard
    exit 0
  else
    echo "upload failed"
    xmessage -nearmouse -buttons "" -timeout 3 "upload failed"
  fi

  ((i = i+1))
done
