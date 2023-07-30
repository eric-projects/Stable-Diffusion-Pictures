#!/bin/bash

# 初始化变量
first_dir=$1  # 数据最外层目录
start_time=$2 # 整理开始日期
end_time=$3   # 整理结束日期
workdir=$(pwd)

dir="$workdir/$first_dir"
landscape_json_dir="$workdir/LANDSCAPE.txt"
landscape_md_dir="$workdir/categories/LANDSCAPE.md"
character_json_dir="$workdir/CHARACTER.txt"
character_md_dir="$workdir/categories/CHARACTER.md"
other_json_dir="$workdir/OTHER.txt"
other_md_dir="$workdir/categories/OTHER.md"
echo ">>>年根目录 $dir"

# 遍历得到所有文件
declare -A otherPictures
declare -A landscapePictures
declare -A characterPictures
# json 信息  时间戳id0,图片名称1,图片路径2
# 需要标签对应有那些图片
landscapeCodes=("风景","landscape","Landscape","LANDSCAPE")
characterCodes=("人物","character","Character","CHARACTER")
otherCodes=("其他","other","Other","OTHER")

function getdir() {
    for element in $(ls $1); do
        dir_or_file=$1"/"$element
        pre_dir=$1
        if [ -d $dir_or_file ]; then
            dirNamePath=${dir_or_file%/*} #去除目录某位的/
            dirName=${dirNamePath##*/}

            t1=$(date -d "$dirName" +%s) # 当前目录时间戳
            t2=$(date -d "$start_time" +%s)
            t3=$(date -d "$end_time" +%s)

            if [ $t3 -ge $t1 -a $t2 -le $t1 ]; then
                getdir $dir_or_file $dirName
                # echo ">>>天子目录  $t1 $t2 $t3"
                current=$(date "+%Y-%m-%d %H:%M:%S")
                timeStamp=$(date -d "$current" +%s)
                timeIndexx=$((timeStamp * 1000 + 10#$(date "+%N") / 1000000)) #将current转换为时间戳，精确到毫秒
                landscapePictures[$timeIndexx]=$dirName
                characterPictures[$timeIndexx]=$dirName
                otherPictures[$timeIndexx]=$dirName
            fi
        else
            current=$(date "+%Y-%m-%d %H:%M:%S")
            timeStamp=$(date -d "$current" +%s)
            currentTimeStamp=$((timeStamp * 1000 + 10#$(date "+%N") / 1000000)) #将current转换为时间戳，精确到毫秒
            fileName=${dir_or_file##*/}                                         # 图片信息
            # 标签解读
            fileInfoArray=(${fileName//-/ })
            tagStr=${fileInfoArray[1]}
            tags=(${tagStr//_/ })
            filePath="/$first_dir/$2"
            for var in ${tags[@]}; do
                if [[ "${landscapeCodes[@]}" =~ "$var" ]]; then
                    landscapePictures[$currentTimeStamp]="$currentTimeStamp*$fileName*$filePath/$fileName"
                elif [[ "${characterCodes[@]}" =~ "$var" ]]; then
                    characterPictures[$currentTimeStamp]="$currentTimeStamp*$fileName*$filePath/$fileName"
                elif [[ "${otherCodes[@]}" =~ "$var" ]]; then
                    otherPictures[$currentTimeStamp]="$currentTimeStamp*$fileName*$filePath/$fileName"
                    # echo "$var in ary"
                fi
            done
            echo $dir_or_file
        fi
    done
}
unset landscapePictures
unset characterPictures
unset otherPictures
getdir $dir $1

# 风景
lsLength=${#landscapePictures[@]}
if [ $lsLength -gt 1 ]; then
    sed -i '1s/^/\n/' $landscape_md_dir
    imgLen=${lsLength- 1}
    imgStr=""
    for var in ${landscapePictures[@]}; do
        fileInfoArray=(${var//\*/ })
        length=${#fileInfoArray[@]}
        echo "数组的元素为: ${fileInfoArray[@]} $length"
        if [ $length -gt 1 ]; then
            name=${fileInfoArray[1]}
            path=${fileInfoArray[2]}
            imgStr="$imgStr <img src=\"https://github.com/eric-projects/Stable-Diffusion-Pictures/blob/main$path\" width=\"100px\">"
            # sed -i '1i <img src="https://github.com/eric-projects/Stable-Diffusion-Pictures/blob/main'"${path}"'" width="100px">' $landscape_md_dir
            # sed -i '1i !['"${name}"']('"${path}"')' $landscape_md_dir
        else
            # 时间
            sed -i '1i '"${imgStr}"'' $landscape_md_dir
            sed -i '1i ## '"${var}"'' $landscape_md_dir
        fi
    done
fi

# 人物
pLength=${#characterPictures[@]}
if [ $pLength -gt 1 ]; then
    sed -i '1s/^/\n/' $character_md_dir
    imgLen=${pLength- 1}
    imgStr=""
    for var in ${characterPictures[@]}; do
        fileInfoArray=(${var//\*/ })
        length=${#fileInfoArray[@]}
        echo "数组的元素为: ${fileInfoArray[@]} $length"
        if [ $length -gt 1 ]; then
            name=${fileInfoArray[1]}
            path=${fileInfoArray[2]}
            imgStr="$imgStr <img src=\"https://github.com/eric-projects/Stable-Diffusion-Pictures/blob/main$path\" width=\"100px\">"
            # sed -i '1i <img src="https://github.com/eric-projects/Stable-Diffusion-Pictures/blob/main'"${path}"'" width="100px">' $landscape_md_dir
            # sed -i '1i !['"${name}"']('"${path}"')' $landscape_md_dir
        else
            # 时间
            sed -i '1i '"${imgStr}"'' $character_md_dir
            sed -i '1i ## '"${var}"'' $character_md_dir
        fi
    done
fi
