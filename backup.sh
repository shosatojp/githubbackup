# default arguments
OUT_DIR=backup
USER_NAME=$GITHUB_USER_NAME
API_TOKEN=$GITHUB_API_TOKEN

usage(){
    echo './list.sh [-u GITHUB_USER_NAME] [-t GITHUB_API_TOKEN] [-o OUT_DIR]'
}

# parse args
while getopts ":u:t:o:" 'opt'; do
    case "$opt" in
        u)
            USER_NAME=${OPTARG}
            ;;
        t)
            API_TOKEN=${OPTARG}
            ;;
        o)
            OUT_DIR=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

if [ "$OUT_DIR" == ''];then
    echo 'Error: out dir'
    exit 1
else
    mkdir -p $OUT_DIR
fi
if [ "$USER_NAME" == '' ];then
    echo 'Error: user name'
    exit 1
fi
if [ "$API_TOKEN" == '' ];then
    echo 'Error: api token'
    exit 1
fi

echo $USER_NAME $API_TOKEN

function archive_repo(){
    repo=$1
    OUT_DIR=$2
    USER_NAME=$3
    API_TOKEN=$4

    echo "$repo"
    dest=$OUT_DIR/$repo.git

    # echo "- cloning"
    git clone --mirror https://$USER_NAME:$API_TOKEN@github.com/$repo.git $dest &> /dev/null

    # # echo "- compressing"
    # tar cfvz $dest.tar $dest &> /dev/null

    # # echo "- removing cache"
    # rm -rf $dest &> /dev/null
}

# main
i=1
repos=''
while [ true ];do
    echo "fetching page $i"
    json=`curl -s -u $USER_NAME:$API_TOKEN https://api.github.com/user/repos?page=$i`
    count=`echo $json | jq '. | length'`

    if [ "$count" == '0' ];then
        break
    else
        repos="$repos $(echo $json | jq -r '.[].full_name')"
        i=$(($i+1))
    fi
done

export -f archive_repo
echo $repos | tr ' ' '\n' | xargs -P8 -l -I % bash -c "archive_repo '%' $OUT_DIR $USER_NAME $API_TOKEN"
