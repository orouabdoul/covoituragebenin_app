#!/bin/bash
cd "C:/Users/HP_PC/StudioProjects/covoiturage_benin_app"
/c/src/flutter/bin/flutter analyze --no-pub > analyze_output.txt 2>&1
echo "Exit: $?" >> analyze_output.txt
