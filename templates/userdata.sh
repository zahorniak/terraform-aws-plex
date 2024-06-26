#!/bin/bash

sudo amazon-linux-extras install epel
sudo yum update -y
sudo yum install -y docker jq s3fs-fuse htop

sudo dd if=/dev/zero of=/swap.file bs=1M count=2048
sudo chmod 600 /swap.file
sudo mkswap /swap.file
sudo swapon /swap.file

# mount s3 bucket
%{ for BUCKET in BUCKETS ~}
mkdir -p /plex-data/${BUCKET}
s3fs ${BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 -o notsup_compat_dir /plex-data/${BUCKET}
%{ endfor ~}

mkdir /plex
s3fs ${CONFIG_BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 -o notsup_compat_dir /plex

# FSTAB
%{ for BUCKET in BUCKETS ~}
echo "s3fs#${BUCKET} /plex-data/${BUCKET} fuse _netdev,iam_role=auto,mp_umask=000,umask=000,use_cache=/tmp,allow_other,ensure_diskfree=500" >> /etc/fstab
%{ endfor ~}

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
ExecStartPre=/bin/bash -c '/usr/bin/docker container inspect plex 2> /dev/null || /usr/bin/docker run -d --name plex --network=host -e PLEX_CLAIM="$CLAIM_TOKEN" -v /plex/config:/config -v /plex-data:/data lscr.io/linuxserver/plex:latest'
ExecStart=/usr/bin/docker start -a plex
ExecStop=/usr/bin/docker stop -t 10 plex

[Install]
WantedBy=multi-user.target
EOF

systemctl start plex
systemctl enable plex.service
