# Arguments

PUB_KEY_OUT="$1"
PRIV_KEY_OUT="$2"

# Validation

function usage {
  echo "Usage: $0 PUBLIC_KEY_OUTPUT_TMP_FILE PRIVATE_KEY_OUTPUT_TMP_FILE" 1>&2
  exit 1
}

test ! -d "$TMP_DIR" \
  && echo "\$TMP_DIR has not been set or it isn't a directory" \
  && exit 1
test -z "$PUB_KEY_OUT" \
  && usage
test -z "$PRIV_KEY_OUT" \
  && usage

# Initialize temporary files

INIT_KEY_TMP_FILE="$TMP_DIR/init_key.txt"
touch $INIT_KEY_TMP_FILE

# Generate the private and public keys

openssl ecparam -name secp256k1 -genkey -noout \
  | openssl ec -text -noout > $INIT_KEY_TMP_FILE \
  2> /dev/null

# Extract the public key, remove the (hex) EC prefix 04 and generate the hash

cat $INIT_KEY_TMP_FILE \
  | grep pub -A 5 \
  | tail -n +2 \
  | tr -d '\n[:space:]:' \
  | sed 's/^04//' \
  | $KECCAK_256SUM_BIN -lx \
  | awk '{print $1}' \
  | tail -c 41 \
  > $PUB_KEY_OUT

# Extract the private key and remove the leading zero byte

cat $INIT_KEY_TMP_FILE \
  | grep priv -A 3 \
  | tail -n +2 \
  | tr -d '\n[:space:]:' \
  | sed 's/^00//' > $PRIV_KEY_OUT

# Clean up temporary files

rm $INIT_KEY_TMP_FILE

# Output the outcome

echo "$PUB_KEY_OUT: 0x$(cat $PUB_KEY_OUT)"
