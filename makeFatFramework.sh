#!/bin/bash
#打通用的framework包。需要在工程目录底下执行，输入target名称。在工程目录下生成framework包
target=$1
if [ -z $target ]
then
	echo "请输入target名称"
	xcodebuild -list
	exit 1
fi

dir=`pwd`
buildDir="$dir/build"

#清除编译临时文件
rm -rf "$buildDir"

function lipoLibs(){
    #copy Release-iphoneos到 目录,然后 lipo -c 一份
    resultDir="$dir"
    [ -d "$resultDir" ] || mkdir -p "$resultDir"
	rm -rf "$resultDir/$target.framework"
    cp -r "$buildDir/Release-iphoneos/$target.framework" "$resultDir/"
    #lipo -c ... -o ..
    lipo -c \
    "$buildDir/Release-iphoneos/$target.framework/$target" \
    "$buildDir/Release-iphonesimulator/$target.framework/$target" \
     -o "$resultDir/$target.framework/$target"
    rm -rf "$resultDir/$target.framework/_CodeSignature"
}
function buildLibs(){
    xcodebuild -target $target -configuration Release -sdk iphoneos build SYMROOT="$buildDir" ONLY_ACTIVE_ARCH="NO"
    xcodebuild -target $target -configuration Release -sdk iphonesimulator build SYMROOT="$buildDir" ONLY_ACTIVE_ARCH="NO" VALID_ARCHS="i386 x86_64"
}
buildLibs
lipoLibs

#清除编译临时文件
rm -rf "$buildDir"
