#!/bin/bash
set -e # Stop on error

mkdir -p build
mkdir -p params
npm install -g snarkjs@latest
pip install -r requirements.txt
cd params
curl https://storage.googleapis.com/zk-jwt-params/jwt-verifier.zkey --output ./jwt-verifier.zkey
curl https://storage.googleapis.com/zk-jwt-params/jwt-verifier_js/jwt-verifier.wasm --output ./jwt-verifier.wasm
cd ../
# gdown "https://drive.google.com/uc?id=1vpXh7w2YRzYK1rNdoKAI4Zu857MFml_R"
# unzip upload-file.zip
# mv upload-file/* params
# curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-creation/contributions/emailwallet-account-creation_00019.zkey --output /root/params/account_creation.zkey
# curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-init/contributions/emailwallet-account-init_00007.zkey --output /root/params/account_init.zkey
# curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-transport/contributions/emailwallet-account-transport_00005.zkey --output /root/params/account_transport.zkey
# curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-claim/contributions/emailwallet-claim_00006.zkey --output /root/params/claim.zkey
# curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-email-sender/contributions/emailwallet-email-sender_00006.zkey --output /root/params/email_sender.zkey
chmod +x circom_proofgen.sh
