yarn run webpack -- -p
rsync -av bin/lib/ do:/var/www/enthraler/lib/
rsync -av bin/assets/ do:/var/www/enthraler/assets/
rsync -av bin/res/ do:/var/www/enthraler/res/
rsync -av bin/index.php do:/var/www/enthraler/index.php
ssh do "cd /var/www/enthraler; php index.php"
