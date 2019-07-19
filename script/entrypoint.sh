#!/bin/sh -x

#set timezone
cp /usr/share/zoneinfo/$TZ /etc/localtime && \
echo $TZ > /etc/timezone

#setup variables
ACME_CONF=/etc/nginx/ssl/${LE_FQDN}.conf
SSL_KEY=/etc/nginx/ssl/${LE_FQDN}.key
SSL_CERT=/etc/nginx/ssl/${LE_FQDN}.cer
SSL_CHAIN=/etc/nginx/ssl/${LE_FQDN}-chain.cer
SSL_DHPARAMS=/etc/nginx/ssl/dhparams.pem
SSL_EXPIRE=1209600 #renew if only 2 weeks left before expiration

#generate dhparams in background
if [ ! -s $SSL_DHPARAMS ]; then
    openssl dhparam -dsaparam -out $SSL_DHPARAMS 4096 &
fi

#check cert's common name and expire date
if [ -s $SSL_CERT ]; then
    CN=$(openssl x509 -noout -subject -in $SSL_CERT)
    openssl x509 -checkend $SSL_EXPIRE -noout -in $SSL_CERT > /dev/null && SSL_EXPIRE=$?
fi

#issue and install cert if all conditions are met
if  [ ! -s $ACME_CONF ] || \
    [ ! -s $SSL_KEY ]   || \
    [ ! -s $SSL_CERT ]  || \
    [ ! -s $SSL_CHAIN ] || \
    [ ! $SSL_EXPIRE -eq 0 ] || \
    [ ! -z "${CN##*${LE_FQDN}*}" ]; then

    #launch nginx
    nginx

    TIMEOUT=1 #to prevent DOSing LE servers in case of reaching issue rate-limits
    until acme.sh --issue -d ${LE_FQDN} -w /usr/share/nginx/html > /dev/null; do
          sleep $TIMEOUT && TIMEOUT=$(expr $TIMEOUT \* 3); done

    nginx -s stop

    acme.sh --install-cert -d $LE_FQDN \
            --key-file        $SSL_KEY \
            --fullchain-file  $SSL_CERT \
            --ca-file         $SSL_CHAIN

    #save acme.sh configs
    cp ~/.acme.sh/$LE_FQDN/${LE_FQDN}.conf /etc/nginx/ssl/
    cp -R ~/.acme.sh/ca /etc/nginx/ssl/
else
    #restore acme.sh configs
    mkdir ~/.acme.sh/$LE_FQDN && cp $ACME_CONF ~/.acme.sh/$LE_FQDN/
    cp -R /etc/nginx/ssl/ca ~/.acme.sh/
fi

#enable example service
cp -n /etc/nginx/service.conf /etc/nginx/conf.d/

#fill configs by actual values
sed -i "s|SSL_KEY|$SSL_KEY|g;s|SSL_CERT|$SSL_CERT|g;s|SSL_CHAIN|$SSL_CHAIN|g;s|LE_FQDN|$LE_FQDN|g" /etc/nginx/conf.d/*.conf

#wait until dhparams are ready
until [ -s $SSL_DHPARAMS ]; do sleep 1; done

#launch nginx and crond in foreground
nginx -g "daemon off;" & crond -f