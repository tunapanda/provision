#!/bin/bash

if ! $( vagrant plugin list | grep vagrant-aws ) > /dev/null
then
    cat >&2 <<EOF

***
** Error: You do not seem to have the vagrant-aws plugin installed.
***

Please run 'sudo vagrant plugin install vagrant-aws' and try again.

EOF
    exit 1
fi

while [ -z "$AWS_KEY" ]
do
    read -p "
** No IAM key found! 
    You can create an IAM user at:
        https://console.aws.amazon.com/iam/home?region=us-west-1#users
    You can avoid this message by running the following before running this script:
        export AWS_KEY=<your_iam_key>
        export AWS_SECRET=<your_iam_secret>
Enter your IAM user's KEY: " AWS_KEY
done

while [ -z "$AWS_SECRET" ]
do
    read -p "Enter the SECRET for key '$AWS_KEY': " AWS_SECRET
done

while [ -z "$AWS_KEYNAME" ]
do
    read -p "
** No AWS key found! 
    You can create an AWS keypair at:
        https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:sort=keyName
    You can avoid this message by running the following before running this script:
        export AWS_KEYNAME=<your_aws_key_name>
        export AWS_KEYPATH=</path/to/key.pem>
Enter your AWS key's NAME: " AWS_KEYNAME
done

[ -z "$AWS_KEYPATH" ] && AWS_KEYPATH="$(pwd)/$AWS_KEYNAME.pem"
while [ ! -e "$AWS_KEYPATH" ]
do
    read -p "
** No credentials file found at $AWS_KEYPATH
Enter the PATH to the .pem file for key $AWS_KEYNAME: " AWS_KEYPATH
done

vagrant up --provider=aws


