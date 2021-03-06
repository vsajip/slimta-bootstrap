#!/usr/bin/env bash

set -e

if [ "$(id -u)" != "0" ]; then
	>&2 echo "usage: sudo $0"
	exit 1
fi

fqdn=$(hostname --fqdn)
export=backup-$(date +%s).tar

tar cf $export -C /var mail

tmpdir=$(mktemp -d)
mkdir -p $tmpdir/json $tmpdir/certs

for key in $(redis-cli --raw keys 'slimta:address:*'); do
	redis-cli --raw get $key > $tmpdir/json/$key.json
done
tar rf $export -C $tmpdir json

cp -a /opt/letsencrypt/etc/lexicon-secrets.sh $tmpdir/certs/
cp -a /etc/ssl/certs/$fqdn/ $tmpdir/certs/
tar rf $export -C $tmpdir certs

rm -rf $tmpdir

echo $export
