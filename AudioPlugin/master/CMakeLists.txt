#
#			CMake Build System
#			"Projucer is weak!!" - inpinseptipin
#
#			BSD 3-Clause License
#
#			Copyright (c) 2024, Satyarth Arora
#			All rights reserved.
#
#			Redistribution and use in source and binary forms, with or without
#			modification, are permitted provided that the following conditions are met:
#
#			1. Redistributions of source code must retain the above copyright notice, this
#			   list of conditions and the following disclaimer.
#
#			2. Redistributions in binary form must reproduce the above copyright notice,
#			   this list of conditions and the following disclaimer in the documentation
#			   and/or other materials provided with the distribution.
#
#			3. Neither the name of the copyright holder nor the names of its
#			   contributors may be used to endorse or promote products derived from
#			   this software without specific prior written permission.
#
#			THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#			AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#			IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#			DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#			FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#			SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#			CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#			OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#			OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

cmake_minimum_required(VERSION 3.10)

project(JucePlugin)

include(FetchContent)

FetchContent_Declare(
	auxport
	GIT_REPOSITORY https://github.com/inpinseptipin/AuxPort
	GIT_TAG	master
)
FetchContent_MakeAvailable(auxport)





FetchContent_Declare(
	JUCE
	GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
	GIT_TAG origin/master
	GIT_SHALLOW ON
	FIND_PACKAGE_ARGS 8.0.0 GLOBAL
)

FetchContent_MakeAvailable(JUCE)


juce_add_plugin(JucePlugin
VERSION 0.01
COMPANY_NAME "JucePlugins"
IS_SYNTH FALSE
NEEDS_MIDI_INPUT FALSE
NEEDS_MIDI_OUTPUT FALSE
IS_MIDI_EFFECT FALSE
PLUGIN_MANUFACTURER_CODE jcpa
PLUGIN_CODE Del0
FORMATS VST3 Standalone
PRODUCT_NAME "JucePlugin"
)

juce_generate_juce_header(JucePlugin)

target_sources(JucePlugin
	PRIVATE
	src/PluginEditor.cpp
	src/PluginProcessor.cpp
	src/PluginEditor.h
	src/PluginProcessor.h
)

target_compile_definitions(JucePlugin
	PUBLIC
	JUCE_WEB_BROWSER=0
	JUCE_USE_CURL=0
	JUCE_VST3_CAN_REPLACE_VST2=0
)

target_link_libraries(JucePlugin
    PRIVATE
        juce::juce_audio_utils
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags)

target_include_directories(${PROJECT_NAME} PUBLIC "${auxport_SOURCE_DIR}/AuxPort")
target_link_libraries(${PROJECT_NAME} PUBLIC AuxPort)