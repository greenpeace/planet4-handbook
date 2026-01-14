#!/usr/bin/env bash

[ -x "$(command -v npm)" ] || { >&2 echo "npm is required but not installed, exiting."; exit 1; }

echo ""
echo "Installing po2json..."
echo ""
npm install po2json

echo ""
echo "Generating .po to .json files..."
echo ""

# Theme strings
pofilenames=$(ls translations/planet4-master-theme/languages/*.po)
for pofilename in $pofilenames
do
   text_domain='planet4-master-theme-backend'
   if [[ "$pofilename" =~ .*"$text_domain".* ]]; then
     suffix='menu-editor'
   else
     suffix='main'
   fi
   # Generate json file from .po file. (Note: The o/p filename should be ${domain}-${locale}-${handle}.json)
   npx po2json "$pofilename" "${pofilename/.po/}-${suffix}.json" -f jed1.x;
done

# Theme blocks strings
pofilenames=$(ls translations/planet4-master-theme/languages/*.po)
for pofilename in $pofilenames
do
   text_domain='planet4-master-theme-backend'
   if [[ "$pofilename" =~ .*"$text_domain".* ]]; then
     suffix='planet4-blocks-theme-editor-script'
   else
     suffix='planet4-blocks-theme-script'
   fi
   # Generate json file from .po file. (Note: The o/p filename should be ${domain}-${locale}-${handle}.json)
   npx po2json "$pofilename" "${pofilename/.po/}-${suffix}.json" -f jed1.x;
done

echo ""
echo "Json file generation done."
echo ""
