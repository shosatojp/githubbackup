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

if [ "$USER_NAME" == '' ];then
    echo 'Error: user name'
    exit 1
fi
if [ "$API_TOKEN" == '' ];then
    echo 'Error: api token'
    exit 1
fi

echo $USER_NAME $API_TOKEN

# main
i=1
while [ true ];do
    json=`curl -s -u $USER_NAME:$API_TOKEN https://api.github.com/user/repos?page=$i`
    count=`echo $json | jq '. | length'`

    if [ "$count" == '0' ];then
        break
    else
        repos=`echo $json | jq -r '.[].full_name'`

        for repo in $repos;do
            echo "$repo"
            dest=$OUT_DIR/$repo

            echo "- cloning"
            git clone https://$USER_NAME:$API_TOKEN@github.com/$repo.git $dest &> /dev/null

            echo "- compressing"
            tar cfvz $dest.tar $dest &> /dev/null

            echo "- removing cache"
            rm -rf $dest &> /dev/null
        done

        i=$(($i+1))
    fi
done

