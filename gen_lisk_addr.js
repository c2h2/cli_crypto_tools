/**
npm install bip39
npm install js-nacl
npm install browserify-bignum

**/
crypto = require('crypto');
bip39 = require('bip39');
bignum = require('browserify-bignum');
var nacl;
require("js-nacl").instantiate(function (nacl_instance) {
  nacl = nacl_instance;
});


passphrase = bip39.generateMnemonic(); //create 12 words
hash = crypto.createHash('sha256').update(passphrase, 'utf8').digest(); //sha256(12 words)

kp = nacl.crypto_sign_keypair_from_seed(hash);
publicKey  = new Buffer(kp.signPk);
privateKey = new Buffer(kp.signSk);
hash = crypto.createHash('sha256').update(publicKey).digest();
temp = new Buffer(8);

for (i = 0; i < 8; i++) {
  temp[i] = hash[7 - i]
};

addr=bignum.fromBuffer(temp).toString() + 'L';

console.log(passphrase);
console.log(addr);
