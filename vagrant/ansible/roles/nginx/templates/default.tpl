server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root {{ nginx.docroot }};
    #index index.php index.html index.htm;

    # Make site accessible from http://localhost/
    server_name {{ nginx.servername }};

    # symfony app
    set $myapp_root /myapp;
    location ~ ^/myapp(/.*)?$ {
        set $myapp_prefix /myapp;
        set $myapp_exec app.php;
        try_files $myapp_root/web$1 @myappapp;
    }
    location ~ ^/myappdev(/.*)?$ {
        set $myapp_prefix /myappdev;
        set $myapp_exec app_dev.php;
        expires off;
        try_files $myapp_root/web$1 @myappapp;
    }
    location @myappapp {
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$myapp_root/web/$myapp_exec;
        fastcgi_param SCRIPT_NAME $myapp_prefix/$myapp_exec;
        #       fastcgi_split_path_info (.+\.php)(/.*)$;
        fastcgi_param HTTPS off;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
    #location /RequestDenied {
    #   proxy_pass http://127.0.0.1:8080;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
        deny all;
    }
}