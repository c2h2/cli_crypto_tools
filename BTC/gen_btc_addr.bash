#!/bin/bash
set -e
if [ $# -eq 0 ]; then
  echo "Missing name, for example generate_key.sh bob"
  exit 1
fi


FILE_NAME=$1
PRIVATE_KEY=${FILE_NAME}_private.pem
PUBLIC_KEY=${FILE_NAME}_public.pem
BITCOIN_PRIVATE_KEY=bitcoin_${FILE_NAME}_private.key
BITCOIN_PUBLIC_KEY=bitcoin_${FILE_NAME}_public.key
BITCOIN_ADDR=bitcoin_${FILE_NAME}_addr.txt

base58=({1..9} {A..H} {J..N} {P..Z} {a..k} {m..z})
bitcoinregex="^[$(printf "%s" "${base58[@]}")]{34}$"

if [ `uname -s` = 'Darwin' ]; then
    TAC="tail -r "
else
    TAC="tac"
fi

decodeBase58() {
    local s=$1
    for i in {0..57}
    do s="${s//${base58[i]}/ $i}"
    done
    dc <<< "16o0d${s// /+58*}+f" 
}

encodeBase58() {
    # 58 = 0x3A
    bc <<<"ibase=16; n=$(tr '[:lower:]' '[:upper:]' <<< "$1"); while(n>0) { n%3A ; n/=3A }" | $TAC |
    while read n
        do echo -n ${base58[n]}
    done
}

checksum() {
    xxd -p -r <<<"$1" | openssl dgst -sha256 -binary | openssl dgst -sha256 -binary | xxd -p -c 80 | head -c 8
}


hash160() {
    openssl dgst -sha256 -binary | openssl dgst -rmd160 -binary | xxd -p -c 80
}

hash160ToAddress() {
    printf "%34s\n" "$(encodeBase58 "00$1$(checksum "00$1")")" |
    sed "y/ /1/"
}

publicKeyToAddress() {
    hash160ToAddress $(openssl ec -in $PRIVATE_KEY -pubout -outform DER |tail -c 65 | hash160) > $BITCOIN_ADDR
}


#"Generating private key"
openssl ecparam -genkey -name secp256k1 -out $PRIVATE_KEY 

#"Generating public key"
openssl ec -in $PRIVATE_KEY -pubout -out $PUBLIC_KEY

#"Generating Bitcoin private key"
openssl ec -in $PRIVATE_KEY -outform DER|tail -c +8|head -c 32|xxd -p -c 32 > $BITCOIN_PRIVATE_KEY 

#"Generating Bitcoin public key"
openssl ec -in $PRIVATE_KEY -pubout -outform DER|tail -c 65|xxd -p -c 65 > $BITCOIN_PUBLIC_KEY 

#"Converting Bitcoin public key to address."
publicKeyToAddress

cat $BITCOIN_ADDR