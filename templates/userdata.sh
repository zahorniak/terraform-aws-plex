#!/bin/bash

# Associate Elastic IP
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
EIP_ID=${EIP_ID}

aws ec2 associate-address \
--instance-id "$INSTANCE_ID" \
--allocation-id "$EIP_ID" \
--allow-reassociation \
--region eu-central-1

# mount s3 bucket
%{ for BUCKET in BUCKETS ~}
mkdir -p /plex-data/${BUCKET}
s3fs ${BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 /plex-data/${BUCKET}
%{ endfor ~}

mkdir /plex
s3fs ${CONFIG_BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 /plex

# get claim token from parameter store
CLAIM_TOKEN=$(aws ssm get-parameter --name /plex/claim_token --region eu-central-1 --with-decryption | jq -r ".Parameter.Value")

systemctl start docker
systemctl enable docker.service

cat >/etc/systemd/system/plex.service <<EOF 
[Unit]
Description=Plex container
After=docker.service plex.mount ${BUCKET_FSTAB_STRING}
Wants=network-online.target docker.socket
Requires=docker.socket

[Service]
Restart=always
ExecStartPre=/bin/bash -c '/usr/bin/docker container inspect plex 2> /dev/null || /usr/bin/docker run -d --name plex --network=host -e PLEX_CLAIM="$CLAIM_TOKEN" -v /plex/config:/config -v /plex-data:/data plexinc/pms-docker'
ExecStart=/usr/bin/docker start -a plex
ExecStop=/usr/bin/docker stop -t 10 plex

[Install]
WantedBy=multi-user.target
EOF

systemctl start plex
systemctl enable plex.service
