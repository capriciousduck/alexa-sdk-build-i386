#!/bin/bash
printf "pcm.!default {\n  type asym\n   playback.pcm {\n     type plug\n     slave.pcm $PULSEAUDIO_OUT\n   }\n   capture.pcm {\n     type plug\n     slave.pcm $PULSEAUDIO_IN\n   }\n}" > /root/.asoundrc

# Audio-Output
if [ "$Audio" == "3.5mm" ]; then
  amixer cset numid=3 1
  echo "Audio forced to 3.5mm jack."
else
  amixer cset numid=3 2
  echo "Audio forced to HDMI."
fi

# $SETTING_LOCALE_VALUE is never updated, so delete the database, 
# see https://gitlab.com/khassel/alexa_sdk_docker/issues/5
rm -f /srv/sdk-folder/application-necessities/deviceSettings.db

sed -i "s:\"defaultLocale\"\:\"en-US\":\"defaultLocale\"\:\"$SETTING_LOCALE_VALUE\":" /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json
sed -i "s:\"defaultTimezone\"\:\"America/Vancouver\":\"defaultTimezone\"\:\"$(cat /etc/timezone)\":" /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json
sed -i "s:amzn1.application-oa2-client.12345678901234567890123456789012:$SDK_CONFIG_CLIENT_ID:" /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json
sed -i "s:SDK_CONFIG_PRODUCT_ID:$SDK_CONFIG_PRODUCT_ID:" /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json
sed -i "s:SDK_CONFIG_DEVICE_SERIAL_NUMBER:$SDK_CONFIG_DEVICE_SERIAL_NUMBER:" /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json

if [ "$WakeWordEngine" = "kittai" ]; then
  export modeldir="/srv/sdk-folder/third-party/snowboy/resources"
elif [ "$WakeWordEngine" = "sensory" ]; then
  export modeldir="/srv/sdk-folder/third-party/alexa-rpi/models"
else
  export modeldir=""
fi

cd /srv/sdk-folder/build

exec ./SampleApp/src/SampleApp /srv/sdk-folder/source/avs-device-sdk/Integration/AlexaClientSDKConfig.json $modeldir $1
