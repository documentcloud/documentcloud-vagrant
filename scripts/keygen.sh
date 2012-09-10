openssl genrsa -des3 -out dev.dcloud.org.key 1024
openssl req -new -key dev.dcloud.org.key -out dev.dcloud.org.csr
cp dev.dcloud.org.key dev.dcloud.org.key.org
openssl rsa -in dev.dcloud.org.key.org -out dev.dcloud.org.key
openssl x509 -req -in dev.dcloud.org.csr -signkey dev.dcloud.org.key -out dev.dcloud.org.crt
