#!/bin/bash
# claim_token_hash: ${CLAIM_TOKEN_SHA256}

sudo amazon-linux-extras install epel
sudo yum update -y
sudo yum install -y docker jq s3fs-fuse htop

sudo dd if=/dev/zero of=/swap.file bs=1M count=2048
sudo chmod 600 /swap.file
sudo mkswap /swap.file
sudo swapon /swap.file

# mount s3 buckets
mkdir -p /plex-data
s3fs ${STORAGE_BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 -o notsup_compat_dir /plex-data

mkdir /plex
s3fs ${CONFIG_BUCKET} -o iam_role=auto -o mp_umask=000 -o umask=000 -o use_cache=/tmp -o allow_other -o ensure_diskfree=500 -o notsup_compat_dir /plex

# create library folders
%{ for LIB in LIBRARIES ~}
mkdir -p /plex-data/${LIB}
%{ endfor ~}

# FSTAB
echo "s3fs#${STORAGE_BUCKET} /plex-data fuse _netdev,iam_role=auto,mp_umask=000,umask=000,use_cache=/tmp,allow_other,ensure_diskfree=500" >> /etc/fstab

CLAIM_TOKEN=$(aws ssm get-parameter --name /plex/claim_token --region eu-central-1 --with-decryption | jq -r ".Parameter.Value")
PUBLIC_IP=$(TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

systemctl start docker
systemctl enable docker.service

cat >/etc/systemd/system/plex.service <<EOF
[Unit]
Description=Plex container
After=docker.service plex.mount
Wants=network-online.target docker.socket
Requires=docker.socket

[Service]
Restart=always
ExecStartPre=/bin/bash -c '/usr/bin/docker container inspect plex 2> /dev/null || /usr/bin/docker run -d --name plex --network=host -e PLEX_CLAIM="$CLAIM_TOKEN" -e ADVERTISE_IP="http://$PUBLIC_IP:32400/" -v /plex/config:/config -v /plex-data:/data lscr.io/linuxserver/plex:latest'
ExecStart=/usr/bin/docker start -a plex
ExecStop=/usr/bin/docker stop -t 10 plex

[Install]
WantedBy=multi-user.target
EOF

systemctl start plex
systemctl enable plex.service
