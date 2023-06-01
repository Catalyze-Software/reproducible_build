#!/bin/sh

if ! command -v dfx /dev/null
then
    echo "dfx could not be found"
    echo "installing dfx"
    sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
fi

#dfx stop
#dfx start --background --clean

dfx deploy sns_event_attendees
dfx deploy sns_events
dfx deploy sns_groups
dfx deploy sns_members
dfx deploy sns_profiles
dfx deploy sns_reports