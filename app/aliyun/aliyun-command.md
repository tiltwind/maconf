
```bash

sudo /bin/bash -c "$(curl -fsSL https://aliyuncli.alicdn.com/install.sh)"

$ aliyun configure
Configuring profile 'default' ...
Aliyun Access Key ID [None]: <Your AccessKey ID>
Aliyun Access Key Secret [None]: <Your AccessKey Secret>
Default Region Id [None]: cn-hangzhou
Default output format [json]: json
Default Language [zh]: zh


aliyun oss cp dist/hkp-test.zip oss://ssjhkp-repo/test/hkp-test-$(date +"%Y%m%d%H%M%S").zip


aliyun fc-open GET /2021-04-06/services


```
