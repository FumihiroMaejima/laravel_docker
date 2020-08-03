# 構成

| 名前 | バージョン |
| :--- | :---: |
| PHP | 7.4(php:7.4-fpm-alpine) |
| MySQL | 8.0 |
| Nginx | 1.17(nginx:1.17-alpine) |
| Laravel | 6.* |

---
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

インストールの確認

```shell-session
$ composer --version
Composer version 1.10.4 2020-04-09 17:05:50
```

ローカルで`composer install`が出来る様に`memory_limit`の設定を`~/.bash_profile`に追記する。

```shell-session
$ vim ~/.bash_profile
alias composer="php -d memory_limit=-1 /usr/local/bin/composer"
```
設定の再読み込み

```shell-session
$ source ~/.bash_profile
```

---
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

### 注意点
git のコミットログを初期化もしくは削除すること。もしくはリベース。

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

---
## Laravelプロジェクトの新規作成

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

---

# 補足
## Laravelを使わない場合

Laravelを使わずにPHPのコードを書く場合、少なくともappとnginxのコンテナは必要になる。

既存のLaravelの「backend」ディレクトリを削除し。新たに「backend」ディレクトリとその中に「public」ディレクトリを作る。

「public」ディレクトリの中にphpファイルを格納すれば良い。

```shell-session
$ cd app
$ composer create-project laravel/laravel=6.* --prefer-dist backend
```

---

## マイグレーションについて

backend/.envの値はプロジェクトrootの.envの値に合わせること。
DB_HOSTはdocker.compose.ymlのmysqlコンテナの名前と同様になる。

```shell-session
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```

マイグレーションは必ずコンテナの内部で実行すること

```shell-session
$ docker-compose exec app php artisan migrate
Migration table created successfully.
Migrating: 2014_10_12_000000_create_users_table
Migrated:  2014_10_12_000000_create_users_table (0.07 seconds)
Migrating: 2019_08_19_000000_create_failed_jobs_table
Migrated:  2019_08_19_000000_create_failed_jobs_table (0.03 seconds)
```

DBのテーブル内の状態を初期化したい場合は、refreshコマンドを使う。

データベース全体を作り直すことが出来る。

```shell-session
$ docker-compose exec app php artisan migrate:refresh
Rolling back: 2019_08_19_000000_create_failed_jobs_table
Rolled back:  2019_08_19_000000_create_failed_jobs_table (0.08 seconds)
Rolling back: 2014_10_12_000000_create_users_table
Rolled back:  2014_10_12_000000_create_users_table (0.03 seconds)
Migrating: 2014_10_12_000000_create_users_table
Migrated:  2014_10_12_000000_create_users_table (0.06 seconds)
Migrating: 2019_08_19_000000_create_failed_jobs_table
Migrated:  2019_08_19_000000_create_failed_jobs_table (0.03 seconds)
```

データベースをリフレッシュし、全データベースシードを実行する

```shell-session
$ php artisan migrate:refresh --seed
```

データベースから全テーブルをドロップする。

```shell-session
$ php artisan migrate:fresh (--seed)
```

---
## 認証機能作成について

一度、migrate:freshなと実行しておくと良い。


laravel/uiのインストール

メモリ消費量が大きい為、コンテナ側で実行する。(php.iniの設定)

```shell-session
$ docker-compose exec app composer require laravel/ui
```

認証系のファイルの作成

```shell-session
$ php artisan ui vue --auth
```

マイグレーションの実行

```shell-session
$ docker-compose exec app php artisan migrate
```

アセットのコンパイル

```shell-session
$ npm install
$ npm run dev or npm run production
```

上記でデフォルトの認証機能が作成出来る。


## Json Web Tokens(JWT)の設定について

tymon/jwt-authのインストール

```shell-session
$ composer require tymon/jwt-auth ^1.0.0
```

config/jwt.phpの作成

```shell-session
$ php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"
```

JWTで用いる秘密鍵の作成

```shell-session
$ php artisan jwt:secret
```

JWTで用いる秘密鍵の作成

```shell-session
$ composer require tymon/jwt-auth ^1.0.0
```

⇨「.env」に「JWT_SECRET」のパラメーターが追加される。

config/auth.phpの設定

```shell-session
$ composer require tymon/jwt-auth ^1.0.0
```


config/auth.phpの設定

「defaults」の「guard」を「api」に、「guards」の「api」の「driver」を「jwt」に変更する。


```PHP
  'defaults' => [
      'guard' => 'api',
      'passwords' => 'users',
  ],

  'guards' => [
      'web' => [
          'driver' => 'session',
          'provider' => 'users',
      ],

      'api' => [
          'driver' => 'jwt',
          'provider' => 'users',
          'hash' => false,
      ],
  ],
```

Userモデルの修正

app/Model/Userを下記の通りに修正する。

・「Tymon\JWTAuth\Contracts\JWTSubject」のuse宣言とimplementsとして設定

・「JWTSubject」で定義されているメソッドを定義する。

＊namespaceに注意する。


```PHP
<?php

namespace App\Model;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use Notifiable;

    /*  省略  */

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.(JWTSubject)
     *
     * @a return mixed
     */
    public function getJWTIdentifier()
    {
        // primary keyを取得
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.(JWTSubject)
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }
}
```

conposer.jsonの修正

Userモデルの位置を変更した為、修正する。

「autoload」の「psr-4」に。下記を記述を追記する。

```Json
"Model\\": "app/Model/"
```


```Json
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Model\\": "app/Model/"
        },
        /* 省略 */
    },
```

composer dump-autoloadの実行

```shell-session
$ composer dump-autoload
```



ルーティングの修正

router/api.phpを下記の通りに修正

＊api.phpに設定されたurlは自動的に「api」というパスが割当てられる為、「api」の記載は不要。


```PHP
Route::group(['prefix' => 'auth'], function () {
    Route::post('login', 'AuthController@login');
});

Route::group(['prefix' => 'auth', 'middleware' => 'auth:api'], function () {
    Route::post('logout', 'AuthController@logout');
    Route::post('refresh', 'AuthController@refresh');
    Route::GET('own', 'AuthController@me');
});

```



コントローラーの作成

```shell-session
 $ php artisan make:controller AuthController
```

内容は下記の通り(コンストラクタとログイン処理のみ抜粋)


```PHP
    /**
     * Create a new AuthController instance.
     *
     * @return void
     */
    public function __construct()
    {
        // Illuminate\Routing\Controller
        $this->middleware('auth:api', ['except' => ['login']]);
    }

    /**
     * Get a JWT via given credentials.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function login()
    {
        $credentials = request(['email', 'password']);

        if (!$token = auth()->attempt($credentials)) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        return $this->respondWithToken($token);
    }
```

テストユーザーの作成


```shell-session
 $ php artisan make:seeder UsersTableSeeder
```

シーダーファイルの作成


```PHP

class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('users')->insert([
            'name' => 'testuser',
            'email' => 'testuser@example.com',
            'password' => bcrypt('testpassword'),
        ]);
    }
}

```

DatabaseSeederの編集


```PHP

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // $this->call(UserSeeder::class);
        $this->call(UsersTableSeeder::class);
    }
}

```


シーディングの実行

```shell-session
 $ php artisan db:seed
```

ログインリクエストの実行


PostmanなどのAPIクライアントで下記のURLでPOSTリクエストを実行する。

```shell-session
localhost/api/auth/login
```

リクエストボディ

```JSON
{
	"email": "v@example.com",
	"password": "testpassword"
}
```

レスポンスボディ

```JSON
{
    "access_token": "ランダム文字列のトークン",
    "token_type": "bearer",
    "expires_in": 3600
}
```

---
# その他

### テーブル作成

```shell-session
 $ php artisan make:migration create_test_table
```

### Model作成

```shell-session
 $ php artisan make:model Model/Test
```

### シーディングファイル作成

```shell-session
 $ php artisan make:seeder TestTableSeeder
```

### ポリシーの作成

```shell-session
$ php artisan make:policy TestPolicy
```

「/app/Policies」ディレクトリにファイルが生成される。

### テストコードの作成
```shell-session
 $ php artisan make:test SampleTest --unit
```


---
# 補足

