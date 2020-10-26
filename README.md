# illumiGenerator
JSONファイルとC-likeな簡易コードからイルミネーション用のArduinoソースコードを生成するツールです。

### To English readers
[here](README_en.md) is README in English.

# 注意
illumiGenerator は私たちの部活動で使うために書かれたツールです。
無線部員にあっては、ハードウェアの仕様を把握の上使用してください。

# 使い方

## 概要
```
$ ./illumiGenerator <jsonfile> <outputname>
```

### 第一引数 \<jsonfile\>
illumiGenerator はJSON形式の設定ファイルを使用します。
詳しい内容については
[JSONファイルの書式](https://github.com/jj1lis/illumiGenerator/blob/master/README.md#%E5%90%84%E7%A8%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E6%9B%B8%E5%BC%8F)
を参照してください。

### 第二引数 \<outputname\>
illumiGenerator が生成する`.ino`ファイルの名前です。末尾の拡張子は自動では付与されません。
```
# 例

$ illumiGenerator hoge.json fuga.ino
  # "fuga.ino"というArduinoファイルが出力される
```

# 各種ファイルの書式

## JSONファイルの書式
illumiGenerator が読み込むJSONファイルの全体は、**過不足なく必ず一つのJSONオブジェクトにしてください**。
一つのファイルが複数のJSONオブジェクトで構成されている場合の動作は未定義です（恐らく例外を吐きます）。

```
{
    "pinMax": 13, 
    "pinMin": 2,
    "pinSW": "A1",

    "flushCycle": 2000,
    "dutyRatio": 0.1,

    "functionSources": [
        "example/func/default.func",
        "example/func/xmas.func",
        "example/func/mochi.func",
        "example/func/oni.func"
    ],  

    "patternOrder" : ["xmas", "mochi", "oni"]
}

```

### 要素一覧
|キー|要素の型|説明|
|----|--------|----|
|"pinMax"|符号なし整数|使用するピンの最大値|
|"pinMin"|符号なし整数|使用するピンの最小値|
|"pinSW"|文字列|モード切替に使用するピン|
|"flushCycle"|符号なし整数|点滅の周期（ミリ秒）|
|"dutyRatio"|小数|PWMにおける出力の最大Duty比|
|"functionSources"|配列（文字列）|制御関数が書かれたファイル|
|"patternOrder"|配列（文字列）|モードの一覧と順番|

`"functionSources"`はいくつあっても、その中のソースコードがどのように分割されていても問題ありません。"patternOrder"に書かれたモードの名前と、"functionSources"で指定されているソースファイルでのモードの名前は一致しなければなりません。
レポジトリ内の[例](example/example.json)も参照してください。

## 制御関数ファイルの書式

### 文法

制御関数ファイルは以下のようなC言語を簡略化させた文法によって記述されます。

```
Jan{
  pin_3-5,9{
    if(0 <= phase && phase <= PI){
      return 1;
    }else{
      return 0;
    }
  }  
}
```
最も外側のカッコに付けられたタグ`Jan`は、その中にある関数がモード`Jan`についての記述であることを意味しています。
複数ファイルにわたって書かれていても、同じタグの関数は同じモード制御にまとめられます。
次のカッコの中身は、出力ピンごとの動作を表記した関数です。名前`pin_3-5,9`はこの関数がピン`3,4,5,9`の動作について指定するものであることを示しています。

すなわち：
```
Tag{
  pin_a,b-c,d{
    //process A
  }
  
  pin_e-f,g,h{
    //process B
  }
}
```
というソースコードはモード`Tag`の時、ピンa,b\~c,dについては`process A`を、ピンe\~f,g,hについては`process B`を実行するよう指定しています。

変数`phase`は周期["flushCycle"](https://github.com/jj1lis/illumiGenerator/blob/master/README.md#%E8%A6%81%E7%B4%A0%E4%B8%80%E8%A6%A7)の中で[0, 2π]と変化する位相です。
`return sin(phase);`と書けば、周期内で正弦関数に従って滑らかにPWMのDuty比を変化させます。
これらの関数の返り値が`1`のときそのピンのDuty比は
["dutyRatio"](https://github.com/jj1lis/illumiGenerator/blob/master/README.md#%E8%A6%81%E7%B4%A0%E4%B8%80%E8%A6%A7)となり、`0`であれば全く点灯しません。

illumiGenerator 内での文法チェックは実装されておらず、内部処理的には関数内の記述がそのまま出力のソースコードに貼り付けられるだけです。
したがってサポートする文法、関数、定数等のより具体的な内容については[公式リファレンス](https://www.arduino.cc/reference/en/)や[日本語訳版](http://www.musashinodenpa.com/arduino/ref/)
を参照しつつ頑張って書いてください。

### "Default"について
["patternOrder"](https://github.com/jj1lis/illumiGenerator/blob/master/README.md#%E8%A6%81%E7%B4%A0%E4%B8%80%E8%A6%A7)
に記載されたタグの他に、`Default`という特別なタグが存在します。
例えばタグ`ModeA`が定義されており、`ModeA`においてはピン3\~5のみについて関数が記述されているとします。使用できるピンは全体で2\~13です。
モード`ModeA`の際にはこれ以外のピンは普通動作せず、常に消灯されたままになります。しかしもし`Default`タグにピン2\~7の動作が記述されていれば、
ピン2,6,7の動作はこれによって補完されます（ピン3\~5は`ModeA`で記述された通りのままです）。
ピン8\~13の動作はどこにも記述されていないため、常に消灯されたままになります。
