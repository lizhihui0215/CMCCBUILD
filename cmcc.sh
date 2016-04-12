#!/bin/bash
set -e
schemas=(ZY="CMCC"
         HB="CMCC_HeBei"
         LN="CMCC_LiaoNing"
         GD="CMCC_GuangDong"
         SH="CMCC_ShangHai"
         ZJ="CMCC_ZheJiang"
         TJ="CMCC_TianJing"
         SD="CMCC_ShanDong"
         JS="CMCC_JiangSu"
         HN="CMCC_HuNan"
         FJ="CMCC_FuJian"
        )

SOURCE_PATH=${BASH_SOURCE[0]}

SOURCE_DIC="$( dirname "$SOURCE_PATH")"

SVN_USERNAME=lizhihui@misquest.com

SVN_PASSWORD=pccw1234

SVN_UPLOADPATH=https://lizhihui%40misquest.com@114.251.247.77/EAM/ASSET/APP/APP_doc/100%20APP/ios%E7%89%88%E6%9C%AC

WORKSPACE=~/Workspace/CMCC

NOW=`date '+%Y-%m-%d-%H-%M-%S'`

ARCHIVE_DIRECTORY=~/Documents/Build/CMCC/$NOW

ARCHIVE_NAME=CMCC.xcarchive

WORKSPACE_NAME=CMCC.xcworkspace

TARGET_PATH=Target

EXPORTOPTIONPLIST=$SOURCE_DIC/ExportOptions.plist

cd $WORKSPACE

function suffix(){
  local index=$1

  local map=${schemas[index]}

  SUFFIX=${map:0:2}
}

function schema_name(){
  local index=$1

  local map=${schemas[index]}

  SCHEMA_NAME=${map:3}
}

function select_schema_name(){

  echo
	echo "WELCOME!  First you have to choose which schema will be used"
	echo "archive the apps."
	echo
	echo "Options (1,2,3,...，Q + enter):"
	echo

  for (( i = 0; i < ${#schemas[*]}; i++ )); do
    schema_name i
    echo "`expr $i + 1`. ${SCHEMA_NAME}"
  done

  printf "please input the Options: "

  read SELECT

  case $SELECT in
    [0-9]*)
      if [[ $SELECT -ge 1 && $SELECT -le ${#schemas[*]} ]]; then
        schema_name `expr $SELECT - 1`
        suffix `expr $SELECT - 1`
      else
        echo
        echo "Please make a selection"
        select_schema_name
      fi
      ;;
    [Qq]*)
			clear
			exit
			;;
    *)
      echo
      echo "Please make a selection"
      select_schema_name
      ;;
  esac

}

function export_ipa(){
  if [[ $SUFFIX == "ZY" ]]; then
    EXPORT_IPA_NAME=EAM_IOS_V1.0\($BUILD_NUMBER\).ipa
  else
    EXPORT_IPA_NAME=EAM_IOS_V1.0\($BUILD_NUMBER\)_$SUFFIX.ipa
  fi
}

function build_number(){
  printf "please input the build number: "

  read BUILD_NUMBER

  case $BUILD_NUMBER in
    [0-9]*)
      ;;
    *)
      echo "must input a number"
      build_number
      ;;
  esac
}

function build_info(){
  echo "build number is " $BUILD_NUMBER

  echo "scnema name is " $SCHEMA_NAME

  echo "SUFFIX is " $SUFFIX

  echo "export ipa name is " $EXPORT_IPA_NAME
}

function build(){
  xcodebuild -workspace $WORKSPACE_NAME -scheme $SCHEMA_NAME -configuration Release clean archive -archivePath $ARCHIVE_DIRECTORY/$ARCHIVE_NAME

  xcodebuild -exportArchive -archivePath $ARCHIVE_DIRECTORY/$ARCHIVE_NAME -exportOptionsPlist $EXPORTOPTIONPLIST -exportPath $ARCHIVE_DIRECTORY/$TARGET_PATH

  mv "$ARCHIVE_DIRECTORY/$TARGET_PATH/${SCHEMA_NAME}.ipa" $ARCHIVE_DIRECTORY/$EXPORT_IPA_NAME
}

function clean(){
  rm -rf $ARCHIVE_DIRECTORY/$ARCHIVE_NAME
  rm -rf $ARCHIVE_DIRECTORY/$TARGET_PATH
}

function uploadsvn(){
  svn import $ARCHIVE_DIRECTORY/$EXPORT_IPA_NAME $SVN_UPLOADPATH/$EXPORT_IPA_NAME --username $SVN_USERNAME --password $SVN_PASSWORD -m "upload {$EXPORT_IPA_NAME}"
}

select_schema_name

build_number

build_info

export_ipa

build

uploadsvn

clean
