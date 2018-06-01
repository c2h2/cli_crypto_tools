import sys
import time
from web3 import Web3

MAX_SEND=1.01

provider="https://rinkeby.infura.io/opi3IPI8GIt6mYCtk0aM"
myaddr   ='0xEdDeff108A1e484d821cECa24Dc67Ec157F0a246'
myprivkey='32byte private key here.'

recp_addr=sys.argv[1]
eth_amount=sys.argv[2]


web3 = Web3(Web3.HTTPProvider(provider))
my_balance = web3.eth.getBalance(Web3.toChecksumAddress(myaddr))
print("MY BALANCE = " + str(my_balance/1E18) + "ETH")

print("SENDING " + recp_addr + " " + eth_amount + " ETH.")

if(float(eth_amount)>MAX_SEND):
    print("SAFTY REASON:" +str(eth_amount)+ "ETH is more than I can send... exiting.")
    exit(1)

if(my_balance<=float(eth_amount)):
    print("NOT ENOUGHT ETH, exiting.")
    exit(2)

signed_txn = web3.eth.account.signTransaction(dict(
    nonce=web3.eth.getTransactionCount(myaddr),
    gasPrice = web3.eth.gasPrice, 
    gas = 100000,
    to=recp_addr,
    value=web3.toWei(eth_amount,'ether')
),myprivkey)

print(signed_txn)
print("Signed, sending tx in 5 seconds.")
time.sleep(2)
print("3 seconds.")
time.sleep(2)
print("1 second.")
time.sleep(1)

txid = web3.eth.sendRawTransaction(signed_txn.rawTransaction).hex()
print("Sent, txid =")

print(txid)
