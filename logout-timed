#!/bin/bash

#Wait 300 seconds before executing the code below
sleep 300

#close all open applications without prompts and logout using AppleScript
/usr/bin/osascript <<EOF
try
    ignoring application responses
        tell application "/System/Library/CoreServices/loginwindow.app" to «event aevtrlgo»
    end ignoring
end try
EOF

exit 0
