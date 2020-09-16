/*
 * Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *     http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#include "KWDProvider/KeywordDetectorProvider.h"
#include <KittAi/KittAiKeyWordDetector.h>

#ifdef KWD_SENSORY
#include <Sensory/SensoryKeywordDetector.h>
#endif

using namespace alexaClientSDK;
using namespace alexaClientSDK::kwd;

std::unique_ptr<kwd::AbstractKeywordDetector> KeywordDetectorProvider::create(
    std::shared_ptr<avsCommon::avs::AudioInputStream> stream,
    avsCommon::utils::AudioFormat audioFormat,
    std::unordered_set<std::shared_ptr<avsCommon::sdkInterfaces::KeyWordObserverInterface>> keyWordObservers,
    std::unordered_set<std::shared_ptr<avsCommon::sdkInterfaces::KeyWordDetectorStateObserverInterface>>
        keyWordDetectorStateObservers,
    const std::string& pathToInputFolder) {
  if (strcmp(getenv("WakeWordEngine"), "kittai") == 0) {
    return alexaClientSDK::kwd::KittAiKeyWordDetector::create(
        stream,
        audioFormat,
        keyWordObservers,
        keyWordDetectorStateObservers,
        pathToInputFolder + "/common.res",
        {{pathToInputFolder + "/alexa.umdl", "ALEXA", atof(getenv("KITT_AI_SENSITIVITY"))}},
        std::stof(getenv("KITT_AI_AUDIO_GAIN")),
        (strcmp(getenv("KITT_AI_APPLY_FRONT_END_PROCESSING"), "true") == 0));
#if defined(KWD_SENSORY) 
  } else if (strcmp(getenv("WakeWordEngine"), "sensory") == 0) {
    return kwd::SensoryKeywordDetector::create(
        stream,
        audioFormat,
        keyWordObservers,
        keyWordDetectorStateObservers,
        pathToInputFolder + "/spot-alexa-rpi-31000.snsr");
#endif        
  } else {
    return nullptr;
  }
}
