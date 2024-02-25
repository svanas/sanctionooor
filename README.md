# sanctionooor

[![GitHub release](https://img.shields.io/github/release/svanas/sanctionooor)](https://github.com/svanas/sanctionooor/releases/latest)
[![GitHub license](https://img.shields.io/github/license/svanas/sanctionooor)](https://github.com/svanas/sanctionooor/blob/main/LICENSE)
[![macOS](https://img.shields.io/badge/os-macOS-green)](https://github.com/svanas/sanctionooor/releases/latest/download/macOS.zip)
[![Windows](https://img.shields.io/badge/os-Windows-green)](https://github.com/svanas/sanctionooor/releases/latest/download/Windows.zip)

![](sanctionooor.png)

## reason to be

On August 9, 2022, the U.S. Department of the Treasury’s Office of Foreign Assets Control (OFAC) decided to [sanction Ethereum-based cryptocurrency mixing service Tornado Cash](https://home.treasury.gov/policy-issues/financial-sanctions/recent-actions/20220808).

This app will tell you what Ethereum RPC providers decided to over-comply with OFAC sanctions and block your transactions, and which ones won't.

## downloads

You can build this app for yourself, or you can download pre-compiled binaries for [Windows](https://github.com/svanas/sanctionooor/releases/latest/download/Windows.zip) or [macOS](https://github.com/svanas/sanctionooor/releases/latest/download/macOS.zip).

## warning

This app will run a request for a U.S. Treasury-sanctioned smart contract on the Ethereum blockchain through [each and every known provider](https://github.com/svanas/ethereum-node-list). We need to assume all of them will log your IP address. Some of them will censor your transaction. Some of those censoring your transaction might block your API key from further usage. Worst case scenario and depending on your jurisdiction, you might incur in penalty or fines by the U.S. Department of Treasury.

## resources

* [How does Tornado Cash work?](https://www.coincenter.org/education/advanced-topics/how-does-tornado-cash-work)
* [Tornado Cash usage post censorship](https://hackmd.io/@gozzy/tornado-cash-post-censorship)

## the may 20, 2023 attack on governance

A hacker took over the Tornado Cash DAO on 2023/05/20 at 07:25:11 UTC, controlling everything the DAO owned, including tornadocash.eth

* check out [this great thread](https://twitter.com/mesquka/status/1660056267753422849) with details about the hack
* don’t use Tornado Nova. Only ever use Tornado Cash on Ethereum.
* don’t use tornadocash.eth because the hacker owns it and can point it to whatever he wants. Use [the last audited UI on IPFS](https://cloudflare-ipfs.com/ipfs/bafybeiezldbnvyjgwevp4cdpu44xwsxxas56jz763jmicojsa6hm3l3rum/)

## the february 2024 attack on tornadocash.eth

The following malicious governance proposals compromised tornadocash.eth:
* https://tornadocash.eth.link/governance/47
* https://tornadocash.eth.link/governance/48

Don't use tornadocash.eth or tornadocash.eth.link. Only ever use [the last audited UI on IPFS](https://cloudflare-ipfs.com/ipfs/bafybeiezldbnvyjgwevp4cdpu44xwsxxas56jz763jmicojsa6hm3l3rum/)

## summary

Because the protocol itself is immutable and the admin key is 0x0, neither OFAC nor the hackers can take it down.

## disclaimer

This app is provided free of charge. There is no warranty and no independent audit has been or will be commissioned. The authors do not assume any responsibility for bugs, vulnerabilities, or any other technical defects. Use at your own risk.
