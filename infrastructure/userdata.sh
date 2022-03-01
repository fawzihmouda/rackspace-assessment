#!/bin/bash
cd /var/www/html
echo "<html><body><h1> Hello World, you are connecting to " > index.html
curl http://169.254.169.254/latest/meta-data/local-hostname >> index.html
echo "  serverd from:" >> index.html
curl http://169.254.169.254/latest/meta-data/placement/availability-zone >> index.html
echo "</h1></body></html>" >> index.html
