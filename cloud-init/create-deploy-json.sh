#!/bin/sh

TemplateName="Template_Ubuntu_20.04"
NetworkName="VM-Network"
DefaultHostName="ubuntu"

UserData=$( base64 --wrap=0 < user-data )

cat <<EOF> ubuntu.json
{
    "DiskProvisioning": "thin",
    "IPAllocationPolicy": "dhcpPolicy",
    "IPProtocol": "IPv4",
    "PropertyMapping": [
        {
            "Key": "instance-id",
            "Value": "id-ovf"
        },
        {
            "Key": "hostname",
            "Value": "$DefaultHostName"
        },
        {
            "Key": "seedfrom",
            "Value": ""
        },
        {
            "Key": "public-keys",
            "Value": ""
        },
        {
            "Key": "user-data",
            "Value": "$UserData"
        },
        {
            "Key": "password",
            "Value": ""
        }
    ],
    "NetworkMapping": [
        {
            "Name": "VM Network",
            "Network": "$NetworkName"
        }
    ],
    "MarkAsTemplate": true,
    "PowerOn": false,
    "InjectOvfEnv": false,
    "WaitForIP": false,
    "Name": "$TemplateName"
}
EOF
