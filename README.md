# Run alexa as docker image

## Setup for raspberry-pi

### Requirements
[please read the wiki-section](https://gitlab.com/khassel/alexa_sdk_docker/wikis/Prepare-your-raspberry-pi)

### Setup
```
git clone --depth 1 -b master https://gitlab.com/khassel/alexa_sdk_docker.git ~/alexa
```

Two WakeWordEngines are supported:
- Kitt-AI: Works for linux and raspberry-pi, you can change the WakeWord "Alexa".
- Sensory: Works for raspberry-pi only, you can't change the WakeWord "Alexa".

Kitt-AI is the default-WakeWordEngine. If you want to use Sensory, you have to edit ```~/alexa/run/docker-compose.yml``` and change the ```WakeWordEngine``` from ```kittai``` to ```sensory```.

### Pull the docker image (also needed for updating the image)
- goto ```cd ~/alexa/run``` and execute ```docker-compose pull```
	
## Setup for linux

### Requirements
- [Docker](https://docs.docker.com/engine/installation/)
- [docker-compose](https://docs.docker.com/compose/install/)


### Setup
```
git clone --depth 1 -b master https://gitlab.com/khassel/alexa_sdk_docker.git ~/alexa
```

### Pull the docker image (also needed for updating the image)
- goto ```cd ~/alexa/run``` and execute ```docker-compose pull```

## Starting the container

### Preparing for the first start of the container

-	Before the first start of the container you need to put valid parameters in the `docker-compose.yml` file in the folder ~/alexa/run. In the environment section of `docker-compose.yml` fill in the following (missing) values:

```
      - SETTING_LOCALE_VALUE=de-DE
      - SDK_CONFIG_DEVICE_SERIAL_NUMBER=123456
      - SDK_CONFIG_CLIENT_ID=
      - SDK_CONFIG_PRODUCT_ID=
```

> These values are used in the `AlexaClientSDKConfig.json` file internally. You find more infos about this [here](https://github.com/alexa/avs-device-sdk/wiki/Create-Security-Profile).
  
-   Now goto ```cd ~/alexa/run``` and execute ```docker-compose up -d```. The container will start, wait a moment and execute ```docker logs al``` to see the logs.
    Search for a similar section in the logs:
	
```
    ##################################
    #       NOT YET AUTHORIZED       #
    ##################################
    ################################################################################################
    #       To authorize, browse to: 'https://amazon.com/us/code' and enter the code: {XXXX}       #
    ################################################################################################
```

Follow the instructions [here](https://github.com/alexa/avs-device-sdk/wiki/Ubuntu-Linux-Quick-Start-Guide#run-and-authorize)
beginning with Point 3. to Point 7.
Execute ```docker logs al``` again to see if the authorization was successful. You should see 
	
```
    ########################################
    #       Alexa is currently idle!       #
    ########################################
```

Now you can talk with Alexa.
	
### Starting and stopping the alexa docker container
- goto ```cd ~/alexa/run``` and execute ```docker-compose up -d```
- in case you want to stop it ```docker-compose down```
- give Alexa ~30 sec. to start, then you can talk with her.


> The container is configured to restart automatically so after executing ```docker-compose up -d``` it will restart with every reboot of your machine.

## Setup speakers and microphone

If you have problems with speakers or microphone please [follow the instuctions here](http://docs.kitt.ai/snowboy/#running-on-pi) 
and check the values for card and device. The `docker-compose.yml` file in the folder `~/alexa/run` contains two parameters:
````
      # params for pulseaudio
      - PULSEAUDIO_OUT="hw:0,0"
      - PULSEAUDIO_IN="hw:1,0"
````

If your setup needs other values, you have to change them here.

## Alternative wakeword with Kitt-AI

### Create new hotword

[Please follow the instructions on the snowboy homepage](https://snowboy.kitt.ai/) and download the pmdl-File, e.g. MyHotword.pmdl

### Update docker-compose.yml

You have to map your own pdml file into the container.
Therefore you have to comment out this line 
```
#      - ./Hilde.pmdl:/srv/sdk-folder/third-party/snowboy/resources/alexa.umdl
```
in ~/alexa/run/docker-compose.yml and replace "Hilde.pdml" with your "MyHotword.pdml". The MyHotword.pdml is expected in ~/alexa/run.
Additionally you have to set the environment parameter 
```
KITT_AI_APPLY_FRONT_END_PROCESSING=false
```
and play with the KITT_AI_SENSITIVITY parameter until it fits (default is 0.6, for "Hilde.pdml" the results are better with 0.47).