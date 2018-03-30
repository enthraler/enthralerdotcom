yarn run webpack -- -p
rsync -av bin/package.json do:/var/www/enthraler/package.json
rsync -av bin/yarn.lock do:/var/www/enthraler/yarn.lock
ssh do "cd /var/www/enthraler; yarn"
rsync -av bin/assets/ do:/var/www/enthraler/assets/
rsync -av bin/server.js.map do:/var/www/enthraler/server.js.map
rsync -av bin/server.js do:/var/www/enthraler/server.js
ssh do "pm2 restart enthraler"
