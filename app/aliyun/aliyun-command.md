## install and configure

```bash

sudo /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"

$ aliyun configure
Configuring profile 'default' ...
Aliyun Access Key ID [None]: <Your AccessKey ID>
Aliyun Access Key Secret [None]: <Your AccessKey Secret>
Default Region Id [None]: cn-hangzhou
Default output format [json]: json
Default Language [zh]: zh

```

## deploy.sh 
```
package_name="$1"

version_file=~/.version/"${package_name}.version"
current_version=$(cat "$version_file" 2>/dev/null)
if [[ ! "${current_version}" =~ ^[0-9]+$ ]]; then
    current_version=0
fi

new_version=$((current_version + 1))
echo "${new_version}" > "${version_file}"
echo "new version: ${new_version}"

bucketname=ssjhkp-repo
osspath="${package_name}/v${new_version}.zip"
echo "oss path: ${osspath}"

aliyun oss cp "dist/${package_name}.zip" "oss://${bucketname}/${osspath}"

echo "deploy function: ${package_name}"
aliyun fc PUT /2023-03-30/functions/"${package_name}" --body "{\"code\":{\"ossBucketName\":\"${bucketname}\",\"ossObjectName\":\"${osspath}\"}}"

old_delete_version=$((current_version - 100))
if (( old_delete_version > 0 )); then
   aliyun oss rm "oss://${bucketname}/${package_name}/v${old_delete_version}.zip"
fi

```
