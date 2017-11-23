#lisk addr create
from mnemonic import Mnemonic
import hashlib
from binascii import hexlify, unhexlify
from nacl import bindings as c
from nacl.exceptions import CryptoError

mnemo = Mnemonic('english')

words = mnemo.generate()
print(words)
hash_object = hashlib.sha256(words)
ed25519_pk, ed25519_sk = c.crypto_sign_seed_keypair(hash_object.digest())

#print hexlify(ed25519_sk)
#print hexlify(ed25519_pk)

pk_sha256_dig=hashlib.sha256(ed25519_pk).hexdigest()
n_letter=2
pk_sha256_dig_array = [pk_sha256_dig[i:i+n_letter] for i in range(0, len(pk_sha256_dig), n_letter)] #split into 2 letters array

temp=[]
for x in range(0, 8):
    temp.append(pk_sha256_dig_array[7-x])

addr_num="".join(temp)
print str(int(addr_num, 16))+"L"
