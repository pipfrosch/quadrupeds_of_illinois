#!/bin/bash

CWD=`pwd`

TMP=`mktemp -d /tmp/QUADILL.XXXXXXXX`

pushd ${TMP}

git clone https://github.com/pipfrosch/quadrupeds_of_illinois.git

cd quadrupeds_of_illinois
# switch to branch goes here

cd TheArticle/EPUB

python3 ../../tools/updateTimestamp.py content.opf
cd ../..

# generate atom file goes here

# generate OPDS goes here

rm -f ${CWD}/opds/epub-noitalics.json

cd TheArticle/EPUB/fonts
rm -f .gitignore
cp -p /usr/local/ePubFonts/ClearSans-BoldItalic-wlatin.ttf .
cp -p /usr/local/ePubFonts/ClearSans-Bold-wlatin.ttf .
cp -p /usr/local/ePubFonts/ClearSans-Italic-wlatin.ttf .
cp -p /usr/local/ePubFonts/ClearSans-Regular-wlatin.ttf .
cp -p /usr/local/ePubFonts/ComicNeue-Bold-wlatin.otf .
cp -p /usr/local/ePubFonts/ComicNeue-Regular-wlatin.otf .
#cp -p /usr/local/ePubFonts/DancingScript-Regular.otf .
cp -p /usr/local/ePubFonts/FiraMono-Medium-wlatin.ttf .
cp -p /usr/local/ePubFonts/FiraMono-Bold-wlatin.ttf .
cd ../..

echo -n application/epub+zip >mimetype

zip -r -X Book.zip mimetype META-INF EPUB
mv Book.zip Quadrupeds-Illinois.kepub.epub

#dyslexia friendly version
find . -type f -print |grep "\.xhtml$" |while read file; do
  cat ${file} \
|sed -e s?"Æ"?"AE"?g \
|sed -e s?"æ"?"ae"?g \
|sed -e s?"Œ"?"OE"?g \
|sed -e s?"œ"?"oe"?g > tmp.sed
cat tmp.sed > ${file}
done
rm -f tmp.sed
cat EPUB/css/noitalics.css >> EPUB/css/a11y.css
zip -r -X Book.zip mimetype META-INF EPUB
mv Book.zip Quadrupeds-Illinois-noitalics.kepub.epub

if hash FuBarMace 2>/dev/null; then
  if [ ! -f ${CWD}/AceReport/noace.tmp ]; then
    ace -f -s -o AceReport Quadrupeds-Illinois.kepub.epub
    rm -rf ${CWD}/AceReport/data
    [ ! -d ${CWD}/AceReport ] && mkdir ${CWD}/AceReport
    mv AceReport/data ${CWD}/AceReport/
    mv AceReport/report.html ${CWD}/AceReport/
    mv AceReport/report.json ${CWD}/AceReport/
    echo "Accessibility report written to AceReport directory"
    echo `pwd`
  fi
fi

mv Quadrupeds-Illinois.kepub.epub ${CWD}/
mv Quadrupeds-Illinois-noitalics.kepub.epub ${CWD}/

popd

if hash FuBarMace 2>/dev/null; then
  if [ -f AceReport/.gitignore ]; then
    if [ ! -f AceReport/noace.tmp ]; then
      git commit -m "update AceReport" AceReport/report.*
    fi
  fi
fi

rm -rf ${TMP}

exit 0

