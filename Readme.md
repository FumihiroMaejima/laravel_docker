# Laravel Docker Environmental

Laravel環境をDockerで構築する為の手順書

# 構成

-PHP:7.4(php:7.4-fpm-alpine)

-MySQL:8.0

-Nginx:1.17(nginx:1.17-alpine)

-Laravel:6.*

# ローカル環境の構築(Mac)

## PHPのバージョン更新

```shell-session
$ brew search php@7
==> Formulae
php@7.2                    php@7.3                    php@7.4

$ brew install php@7.4
```

インストール中に下記のメッセージがある。
下記のメッセージを頼りに$PATHと設定する。

```shell-session
If you need to have apr first in your PATH run:
  echo 'export PATH="/usr/local/opt/apr/bin:$PATH"' >> ~/.bash_profile
```

「~/.bash_profile」にPATHの設定を追記。
「~/.bash_profile」の読み込み。

```shell-session
$ echo 'export PATH="/usr/local/opt/apr/bin:$PATH"' >> ~/.bash_profile
$ source ~/.bash_profile
```

PHPのサービスの起動。

```shell-session
$ brew services start php
==> Successfully started `php` (label: homebrew.mxcl.php)
```

更新の確認。

```shell-session
$ php -v
PHP 7.4.4 (cli) (built: Mar 19 2020 20:14:52) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.4, Copyright (c), by Zend Technologies
```

## Composerのインストール

opensslのインストール

```shell-session
$ brew install openssl
```

Composerのインストール

```shell-session
$ curl -sS https://getcomposer.org/installer | php
```

インストールしたファイルを「/usr/local/bin/」に移動させる。

```shell-session
$ ls
composer.phar
$ mv composer.phar /usr/local/bin/composer
```

インストールの確認

```shell-session
$ composer --version
Composer version 1.10.4 2020-04-09 17:05:50
```

# 開発環境構築

## プロジェクト新規作成直後に必須の作業

### laravel_dockerリポジトリのclone

```shell-session
$ git clone https://github.com/FumihiroMaejima/laravel_docker your_project
```

### masterブランチのチェックアウト

デフォルトブランチがdevelopの為、masterブランチをチェックアウトする。

```shell-session
$ git checkout -b master remotes/origin/master
```

### 現在のremoteのURLの確認

```shell-session
$ git remote -v
origin	https://github.com/FumihiroMaejima/laravel_docker (fetch)
origin	https://github.com/FumihiroMaejima/laravel_docker (push)
```


### remoteリポジトリのURLの変更

```shell-session
$ git remote set-url origin https://github.com/Your_Name/your_project
$ git remote -v
origin	https://github.com/Your_Name/your_project (fetch)
origin	https://github.com/Your_Name/your_project (push)
```


### masterとdevelopブランチをremoteにpushする。

```shell-session
$ git push origin master
$ git push origin develop
```

### git-flowの初期化を行う。

```shell-session
$ git flow init
```


### env_exampleをコピペして.envを作る。
APP_PORTは現状設定不要。
nginxのポート設定は要注意が必要。

### Laravel version7系のプロジェクトを用意する場合

既存の「backend」ディレクトリをリネームして新しく作成する

```shell-session
$ composer create-project laravel/laravel=7.* --prefer-dist backend
```

## 不要ファイルの削除

＊コンテナイメージの作り直し時も同様

```shell-session
$ docker-compose down --rmi all
$ docker-compose down
$ docker-compose up -d

```

## Laravelプロジェクトの作成(新規作成時)

dockerコンテナとマウントする為の「backend」ディレクトリはローカルで作成する。
「app」ディレクトリに移動してcomposerでプロジェクトを新規作成する。

バージョン:6.*

プロジェクト名:backend

*(フロントエンドとの連携を考慮しての命名)

```shell-session
$ cd app
$ composer create-project laravel/laravel=6.* --prefer-dist backend
```

## パッケージのインストール

バージョン7系をインストールする場合
「GuzzleHttpClient」はバージョン7系だとデフォルトでインストールされる。

```shell-session
$ composer require guzzlehttp/guzzle
$ composer require --dev nunomaduro/phpinsights
$ composer require --dev barryvdh/laravel-debugbar
$ composer require --dev friendsofphp/php-cs-fixer
$ composer require --dev squizlabs/php_codesniffer
$ composer require --dev phpmd/phpmd
$ composer require --dev codedungeon/phpunit-result-printer
$ composer require --dev barryvdh/laravel-ide-helper
```

php-cs-fixer,phpcs,phpmdの設定ファイルを格納する

```shell-session
backend/.php_cs
backend/phpcs.xml
backend/ruleset.xml
```

CI関係のコマンド

```shell-session
vendor/bin/phpunit --testdox
vendor/bin/php-cs-fixer fix -v
vendor/bin/phpcs --standard=phpcs.xml --extensions=php .
vendor/bin/phpmd . text ruleset.xml --suffixes php --exclude node_modules,resources,storage,vendor
```

# 補足
## Laravelを使わない場合

Laravelを使わずにPHPのコードを書く場合、少なくともappとnginxのコンテナは必要になる。

既存のLaravelの「backend」ディレクトリを削除し。新たに「backend」ディレクトリとその中に「public」ディレクトリを作る。

「public」ディレクトリの中にphpファイルを格納すれば良い。

```shell-session
$ cd app
$ composer create-project laravel/laravel=6.* --prefer-dist backend
```
