#!/bin/sh
if ! command -v brew /dev/null
then
    echo "brew could not be found"
    echo "please install homebrew"
    exit
fi

if ! command -v jq /dev/null
then
    echo "jq could not be found"
    echo "installing jq"
    brew install coreutils jq
fi

echo 'export PATH="$PATH:/opt/homebrew/bin/:/usr/local/opt/coreutils/libexec/gnubin"' >> "${HOME}/.bashrc"
git clone git@github.com:dfinity/sns-testing.git
cd sns-testing
git clone https://github.com/dfinity/internet-identity.git
git clone https://github.com/dfinity/nns-dapp.git
bash install.sh

DFX_NET_JSON="${HOME}/.config/dfx/networks.json"
mkdir -p "$(dirname "${DFX_NET_JSON}")"
cp "$DFX_NET_JSON" "${DFX_NET_JSON}.tmp" 2>/dev/null  # save original config if present
echo '{
   "local": {
      "bind": "0.0.0.0:8080",
      "type": "ephemeral",
      "replica": {
         "subnet_type": "system"
      }
   }
}' > "${DFX_NET_JSON}"
./bin/dfx start --background --clean; \
mv "${DFX_NET_JSON}.tmp" "$DFX_NET_JSON" 2>/dev/null  # restore original config if it was present

cd sns-testing

./setup_locally.sh
#./run_basic_scenario.sh

cd ..

dfx deploy sns_event_attendees
dfx deploy sns_events
dfx deploy sns_groups
dfx deploy sns_members
dfx deploy sns_profiles
dfx deploy sns_reports

cd sns-testing
./deploy_sns.sh ../sns.yml

canister_ids=../.dfx/local/canister_ids.json

if [ ! -f "$canister_ids" ]; then
        echo "canister_ids file $canister_ids not valid"
        exit 2
fi

json=$(cat $canister_ids)

readJsonConfig() {
        echo $json | jq -r $1
}

echo $(readJsonConfig ".sns_event_attendees.local")
echo $(readJsonConfig ".sns_events.local")
echo $(readJsonConfig ".sns_groups.local")
echo $(readJsonConfig ".sns_members.local")
echo $(readJsonConfig ".sns_profiles.local")
echo $(readJsonConfig ".sns_reports.local")

./register_dapp.sh $(readJsonConfig ".sns_event_attendees.local")
./register_dapp.sh $(readJsonConfig ".sns_events.local")
./register_dapp.sh $(readJsonConfig ".sns_groups.local")
./register_dapp.sh $(readJsonConfig ".sns_members.local")
./register_dapp.sh $(readJsonConfig ".sns_profiles.local")
./register_dapp.sh $(readJsonConfig ".sns_reports.local")

./open_sns_sale.sh
./participate_sns_sale.sh 2 200
#./finalize_sns_sale.sh

#./cleanup.sh