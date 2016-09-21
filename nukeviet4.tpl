server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;

    location / {

        location ~* ^.+\.(jpeg|jpg|png|gif|bmp|ico|svg|css|js)$ {
            expires     max;
        }

        location ~ [^/]\.php(/|$) {
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            if (!-f $document_root$fastcgi_script_name) {
                return  404;
            }

            fastcgi_pass    %backend_lsnr%;
            fastcgi_index   index.php;
            include         /etc/nginx/fastcgi_params;
        }
    }

    error_page  403 /error/404.html;
    error_page  404 /error/404.html;
    error_page  500 502 503 504 /error/50x.html;

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location ~* "/\.(htaccess|htpasswd)$" {
        deny    all;
        return  404;
    }
	
	if ($request_filename ~ /robots.txt$){
		rewrite ^(.*)$ /robots.php?action=$http_host break;
	}	

	rewrite ^/(.*?)install/check.rewrite$ /install/rewrite.php break;
	rewrite ^/(.*?)sitemap\.xml$ /index.php?nv=SitemapIndex break;
	rewrite "^/(.*?)sitemap\-([a-z]{2})\.xml$" /index.php?language=$2&nv=SitemapIndex break;
	rewrite "^/(.*?)sitemap\-([a-z]{2})\.([a-zA-Z0-9-]+)\.xml$" /index.php?language=$2&nv=$3&op=sitemap break;

	if (!-e $request_filename){
		rewrite (.*)(\/|\.html)$ /index.php;
		rewrite /(.*)tag/(.*)$ /index.php;
	}

	location ~ ^/admin/([a-z0-9]+)/(.*)$ {
		deny all;
	}

	location ~ ^/(config|includes)/(.*)$ {
		deny all;
	}

	location ~ ^/data/(cache|config|ip|ip6|logs)/(.*)$ {
		deny all;
	}

	location ~ ^/(files|uploads|themes)/(.*).(php|ini|tpl|php3|php4|php5|phtml|shtml|inc|asp|aspx|pl|py|jsp|asp|sh|cgi)$ {
		deny all;
	}	

    include     /etc/nginx/conf.d/phpmyadmin.inc*;
    include     /etc/nginx/conf.d/phppgadmin.inc*;
    include     /etc/nginx/conf.d/webmail.inc*;

    include     %home%/%user%/conf/web/nginx.%domain%.conf*;
}
