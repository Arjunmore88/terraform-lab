#!/bin/bash
dnf install -y nginx
cat > /usr/share/nginx/html/index.html <<HTML
<h1>Hello from Terraform!</h1>
<p>Instance: $(hostname)</p>
HTML
systemctl enable --now nginx
