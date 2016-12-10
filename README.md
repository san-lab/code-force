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
| Santander Brasil | BRL | http://169.57.163.237:8001/ | http://10.150.230.2:8001/ | BRSANOMNI00000000 |
| Acme Bank Brasil | BRL | http://169.57.163.238:8001/ | http://10.150.230.20:8001/ | BRACMOMNI00000000 |
| Santander US | USD | http://169.57.163.243:8001/ | http://10.150.230.11:8001/ | USSANOMNI00000000 |
| Santander UK | GBP | http://169.57.163.242:8001/ | http://10.150.230.25:8001/ | GBSANOMNI00000000 |
| Santander España | EUR | http://169.57.163.253:8001/ | http://10.150.230.32:8001/ | ESSANOMNI00000000 |

And we have created pre-funded accounts for all of you in all banks. To access them for the first time just point to the URL and click on the "forgot pasword" link. Then enter your email (the one you registered with) and you will receive an email with the password. You then can enter your account and make transfers

## Tokenizing and detokenizing money

In order to tokenize money into the smart contract, simply make a transfer to the corresponding omnibus account and paste your ethereum address into the message field (nothing else, and no trailing spaces etc, but anyway your money will be returned if there is no account that matches the address). It is that simple ;-)

In order to detokenize money, you have to call the redeem_funds method and specify the last four digits of your bank account. Bear in mind that the tokenizer will check only for those bank accounts that have actually sent money to the cryptobank wallet with that ethereum address, since otherwise it would not be able to relate bank accounts and ethereum addresses. The practical implication of this is that you must do a cash in before attempting to do a cash out, so the bank account you want to pay the money to is actually linked to the address from which you are asking the redemption.

## The SanCash wallet

Finally, we also provide a simple wallet service to create and manage accounts in the cryptobank smart contract. You can access them here:

| SanCash          | Currency | external URL | Internal URL |
|------------------|----------|--------------|--------------|
| Santander Brasil | BRL | http://169.57.163.237:8003/ | http://10.150.230.2:8003/ |
| Acme Bank Brasil | BRL | http://169.57.163.238:8003/ | http://10.150.230.20:8003/ |
| Santander US | USD | http://169.57.163.243:8003/ | http://10.150.230.11:8003/ |
| Santander UK | GBP | http://169.57.163.242:8003/ | http://10.150.230.25:8003/ |
| Santander España | EUR | http://169.57.163.253:8003/ | http://10.150.230.32:8003/ |

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

## The SanCash API

Ok, so some of you asked for a simple API to access the SanCash wallet service. Again, this was just supposed to be a simple demonstrator, but for those of you that are not that familiar with Ethereum this can actually be helpful.

So I put together a simple RESTful API to access and manage the wallet. Again, this is really simple to hack, so please do behave ;-)

To access the RESTful web services, you simply need to access the SanCash wallets using the "/service/" directory:

| SanCash          | Currency | external URL | Internal URL |
|------------------|----------|--------------|--------------|
| Santander Brasil | BRL | http://169.57.163.237:8003/services/ | http://10.150.230.2:8003/services/ |
| Acme Bank Brasil | BRL | http://169.57.163.238:8003/services/ | http://10.150.230.20:8003/services/ |
| Santander US | USD | http://169.57.163.243:8003/services/ | http://10.150.230.11:8003/services/ |
| Santander UK | GBP | http://169.57.163.242:8003/services/ | http://10.150.230.25:8003/services/ |
| Santander España | EUR | http://169.57.163.253:8003/services/ | http://10.150.230.32:8003/services/ |

The commands have simple web service syntax, and you will need to authenticate in your calls. The general syntax is the following:

```
http://<SanCash IP>:8003/services/?user=<_your_login_>&pass=<_your_passphrase_>&command=<_a_command>[&_params_=_value_]
```

You will get in return a json object with two elements:
i) "Success": either true or false
ii) "Data": the corresponding data in json format, or the reason why the command failed if it did


The following services are available:

- *Read balance* (`command=readbalance`) - this is to retrieve your balance. Example:

```
http://169.57.163.237:8003/services/?user=julio&pass=mypass&command=readbalance
```

... after which I get something like:

```
{"Success":true,"Data":"400.00"}
```

- *Does account exist* (`doesaccountexist`) - this is to check whether an acount with a given number exists. It takes one extra argument: _whichaccount_, to specify the account number you want to check. Example:

```
http://169.57.163.237:8003/services/?user=julio&pass=mypass&command=doesaccountexist&whichaccount=2
```

... after which I get:

```
{"Success":true,"Data":true}
```

- *Which account* (`whichaccount`) - this is to retrieve the account number from an ethereum public key. Again, this takes an extra argument: _whichaddress_, to specify the address to check. Example:

```
http://169.57.163.237:8003/services/?user=julio&pass=mypass&command=whichaccount&whichaddress=0xc6d1463b3b2a26dd29d42b56e3f9f14b21faeb6e
```
... which results in:

```
{"Success":true,"Data":2}
```

- *Make transfer* (`maketransfer`) - this is to actually make a transfer from your account (the one you authenticate from). It takes three additional arguments: _toaccount_ (the destination account for the transfer), _amount_ (the amount to transfer), and _message_ (the message that accompanies the transfer). Example:

```
http://169.57.163.237:8003/services/?user=julio&pass=mypass&command=maketransfer&toaccount=4&amount=4.5&message=%22Hello%20Marina%22
```

... and what you get is the hash of the transaction:

```
{"Success":true,"Data":"0xfb80f1e310163d151925fc71ac1d9a7c3af5754127b243d2768ffa5421a145f9"}
```

- *Read transaction* (`readtransaction`) - this is to retrieve a transaction sent to the nextwork, like for example the transfer as per the above. It takes one argument: _txhash_, the hash of the transaction (the same you get in the maketransfer call). Example:

```
http://169.57.163.237:8003/services/?user=julio&pass=mypass&command=readtransaction&txhash=0xfb80f1e310163d151925fc71ac1d9a7c3af5754127b243d2768ffa5421a145f9
```

The return data has four fields: _mined_ (whether the transaction has been mined or not), _n_blocks_since_mining_ (self explanatory, remember to wait for a few blocks if you really want transactions to be final), _succeded_ (whether the transaction was successful or threw an exception), and _tx_details_ (all the fields of a normal ethereum transaction). Example:

```
{"Success":true,"Data":{"mined":true,"n_blocks_since_mining":30,"succeded":true,"tx_details":{"Hash":[251,128,241,227,16,22,61,21,25,37,252,113,172,29,154,124,58,245,117,65,39,178,67,210,118,143,250,84,33,161,69,249],"Nonce":1,"BlockHash":[197,88,36,156,239,198,217,193,59,79,60,11,177,32,135,56,71,74,231,149,60,5,9,130,140,69,100,45,197,37,31,139],"BlockNumber":12614,"TransactionIndex":0,"From":[198,209,70,59,59,42,38,221,41,212,43,86,227,249,241,75,33,250,235,110],"To":[255,147,141,26,68,129,53,105,176,85,85,221,244,88,83,181,153,17,24,154],"Value":0,"GasPrice":0,"Gas":4700000,"Input":"0x573d3a23000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001c200000000000000000000000000000000000000000000000000000000000000042248656c6c6f204d6172696e6122000000000000000000000000000000000000"}}}
```

(sorry this last one has such an ugly output, this is because of the json serializer in go, you will have to translate this to an ascii string in order to parse the output more comfortably)

Enjoy! j



