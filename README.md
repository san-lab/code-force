# Overview
This is the Code Force repository for blockchain related stuff

## Contents:
- The presentation shown during the warm up session with the basi information
- The source code of the cryptobank smart contract (cryptobank.sol), i.f. the one the tokenizer uses to store digital money (see the presentation)
- The genesis file used to initialize the ethereum blockchain. You can use the standard geth client
- The scripts used to initialize the blockchain, to connect the node, and to attach to the client

## Connecting to the blockchain

In order to access the blockchain , you should initialize it using the genesis file provided. Here's the command I used:
```
geth  --identity "<your identity here>" --port "8004" --networkid 23723 --gasprice 0 --gpomin 0 --gpomax 0 --datadir ~/Ethereum/julionet init ~/Ethereum/julionetGenesys.json
```
You can of course use whatever data directory you want, and the correct path to the genesis file.

As explained in the presentation, we are using a private deployment with no cost of gas, as this is how it will be used in a private setting later on within Santander's firewall. We know this is easy to destabilize, so please be careful!

In order to connect the nodes, this is the command I use:
```
geth --identity "<your identity here>" --port "8004" --networkid 23723 --gasprice 0 --gpomin 0 --gpomax 0 --datadir ~/Ethereum/julionet --rpc --rpcapi admin,debug,eth,miner,net,personal,shh,txpool,web3
```

And this is how I attach to the node:
```
export ipcfile=~/Ethereum/julionet/geth.ipc
geth attach ipc:$ipcfile
```
... but you already know all this ;-)

## Using the demo banks

The demo banks are very simple utilities just to play around with the concept of tokenizing money. So ple do not expect much from them ;-)

They can essentially hold money in user accounts and also make internal transfers - and not much more than that. But the beauty is that they are connected to the tokenizers, and therefore one can make transfers to the omnibus account to tokenize the money into the cryptobank smart contract, which is where things get interesting.

We have deployed 5 demo banks in different currencies for you to play with:

| Bank | Currency | external URL | Internal URL | Omnibus account |
|------|----------|--------------|--------------|-----------------|
| Santander Brasil | BRL | TBD | TBD | BRSANOMNI00000000 |
| Acme Bank Brasil | BRL | TBD | TBD | BRACMOMNI00000000 |
| Santander US | USD | TBD | TBD | USSANOMNI00000000 |
| Santander UK | GBP | TBD | TBD | GBSANOMNI00000000 |
| Santander España | EUR | TBD | TBD | ESSANOMNI00000000 |

And we have created pre-funded accounts for all of you in all banks. To access them for the first time just point to the URL and click on the "forgot pasword" link. Then enter your email (the one you registered with) and you will receive an email with the password. You then can enter your account and make transfers

## Tokenizing and detokenizing money

In order to tokenize money into the smart contract, simply make a transfer to the corresponding omnibus account and paste your ethereum address into the message field (nothing else, and no trailing spaces etc, but anyway your money will be returned if there is no account that matches the address). It is that simple ;-)

In order to detokenize money, you have to call the redeem_funds method and specify the last four digits of your bank account. Bear in mind that the tokenizer will check only for those bank accounts that have actually sent money to the cryptobank wallet with that ethereum address, since otherwise it would not be able to relate bank accounts and ethereum addresses. The practical implication of this is that you must do a cash in before attempting to do a cash out, so the bank account you want to pay the money to is actually linked to the address from which you are asking the redemption.

## The SanCash wallet

Finally, we also provide a simple wallet service to create and manage accounts in the cryptobank smart contract. You can access them here:

| SanCash          | Currency | external URL | Internal URL |
|------------------|----------|--------------|--------------|
| Santander Brasil | BRL      | TBD          | TBD          |
| Acme Bank Brasil | BRL      | TBD          | TBD          |
| Santander US | USD | TBD | TBD |
| Santander UK | GBP | TBD | TBD |
| Santander España | EUR | TBD | TBD |

With this service, you can very easily generate create wallet accounts with their corresponding addresses and key files, and you can do transfers and redemptions very easily.

## Putting it all together

Maybe you want to do a little tutorial ;-)
- Go to the corresponding sancash and create a wallet
- Then enter you login and note your ethereum address (pls wait for a minute or so until your account is active)
- Go to the demo bank and retrieve your password through email
- Access your demobank account with your password
- Make a transfer to the corresponding omnibus account, pasting your ethereu address in the message field
- Go to your sancash account and watch how your cryptomoney arrives
- Make a transfer to a fellow participant if you want ;-)
- Make a redemption, specifiying the last four digits of your bank account
- Go back to your demo bank account and watch the money arrive safely back to the bank
