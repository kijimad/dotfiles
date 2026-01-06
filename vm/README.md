# Linux Mint テスト環境構築手順

## 概要

QEMU/KVMのbacking fileを使って、ベースイメージを変更せずにテスト環境を構築します。
すべてのファイルは`dotfiles/vm/`ディレクトリに配置されます。

## ディレクトリ構造

```
dotfiles/
└── vm/
    ├── README.md              # このファイル
    ├── setup-base.sh          # ベースイメージセットアップスクリプト
    ├── create-test-vm.sh      # テストVM作成スクリプト
    ├── start-test-vm.sh       # テストVM起動スクリプト
    ├── reset-test-vm.sh       # テストVMリセットスクリプト
    ├── mint-base.qcow2        # ベースイメージ（gitignore対象）
    ├── mint-test.qcow2        # テスト用イメージ（gitignore対象）
    └── *.iso                  # ISOファイル（gitignore対象）
```

## 手順

### 1. Linux Mint ISOのダウンロード

```bash
cd ~/dotfiles/vm
wget https://mirrors.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso
```

または手動でダウンロードして`~/dotfiles/vm/`に配置してください。

### 2. ベースイメージのセットアップ

```bash
cd ~/dotfiles/vm
./setup-base.sh
```

このスクリプトは:
1. ベースイメージ（mint-base.qcow2）を作成
2. ISOからLinux MintをインストールするためのVMを起動
3. インストール後、手動でシャットダウン

インストール完了後、VMをシャットダウンしてください。

### 3. ベースイメージの初期設定（オプション）

```bash
# ベースイメージを起動
qemu-system-x86_64 \
  -enable-kvm \
  -m 8192 \
  -smp 4 \
  -hda ~/dotfiles/vm/mint-base.qcow2 \
  -vga virtio \
  -display gtk
```

VM内で:
```bash
# システムアップデート
sudo apt update && sudo apt upgrade -y

# 基本ツール（curl, gitは既にインストール済みの場合もある）
sudo apt install -y curl git vim

# シャットダウン
sudo shutdown -h now
```

### 4. ベースイメージを読み取り専用に設定

```bash
cd ~/dotfiles/vm
chmod 444 mint-base.qcow2
```

### 5. テスト用VMの作成

```bash
cd ~/dotfiles/vm
./create-test-vm.sh
```

これで`mint-test.qcow2`が作成されます（backing file使用）。

### 6. テスト用VMの起動

```bash
cd ~/dotfiles/vm
./start-test-vm.sh
```

VM内でnix-setup.shをテスト:
```bash
# dotfilesをクローン
git clone https://github.com/<username>/dotfiles.git ~/dotfiles

# nix-setup.shを実行
cd ~/dotfiles
./nix-setup.sh
```

### 7. テスト環境のリセット

テストに失敗した場合や再テストしたい場合:

```bash
cd ~/dotfiles/vm
./reset-test-vm.sh
```

これでクリーンな状態から再スタートできます。

## スクリプトの説明

### setup-base.sh
ベースイメージを作成し、インストール用VMを起動します。

### create-test-vm.sh
ベースイメージからbacking fileを使用してテスト用イメージを作成します。

### start-test-vm.sh
テスト用VMを起動します。

### reset-test-vm.sh
テスト用イメージを削除して再作成し、クリーンな状態に戻します。

## イメージの状態確認

```bash
cd ~/dotfiles/vm

# イメージ情報の確認
qemu-img info mint-test.qcow2

# ディスク使用量
du -h *.qcow2
```

## Tips

### ホストとゲスト間のファイル共有

dotfilesディレクトリをゲストと共有する場合:

```bash
# start-test-vm.shを編集して以下を追加:
# -virtfs local,path=$HOME/dotfiles,mount_tag=dotfiles,security_model=passthrough,id=dotfiles
```

ゲスト内で:
```bash
sudo mkdir -p /mnt/dotfiles
sudo mount -t 9p -o trans=virtio,version=9p2000.L dotfiles /mnt/dotfiles
```

### スナップショット

特定の状態を保存したい場合:

```bash
cd ~/dotfiles/vm

# スナップショット作成
qemu-img snapshot -c before-test mint-test.qcow2

# スナップショット一覧
qemu-img snapshot -l mint-test.qcow2

# スナップショットに戻す
qemu-img snapshot -a before-test mint-test.qcow2
```

## トラブルシューティング

### ベースイメージが読み取り専用でない場合

```bash
cd ~/dotfiles/vm
chmod 444 mint-base.qcow2
```

### テストVMが起動しない

```bash
# backing fileの確認
qemu-img info mint-test.qcow2

# ベースイメージが存在するか確認
ls -la mint-base.qcow2
```
