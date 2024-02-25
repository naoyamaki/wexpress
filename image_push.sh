#!/bin/sh

# AWSのアカウントIDをawscliから取得（複数アカウントを接している場合は注意）
AWS_ACOUNT_ID=`aws sts get-caller-identity --query Account --output text`

# AWS ECRへログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin https://${AWS_ACOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com | exit 1

docker build  --no-cache --pull -t wp-apache:latest ./wp-apache | exit 1

# appサーバのイメージを作成してECRへプッシュ
docker tag wp-apache:latest ${AWS_ACOUNT_ID}.dkr.ecr.ap-n ortheast-1.amazonaws.com/wp-apache:latest
docker push ${AWS_ACOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/wp-apache:latest