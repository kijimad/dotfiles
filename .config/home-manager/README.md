## 運用

```shell
# 初回
nix run home-manager -- switch --flake .#violet

# 以降
home-manager switch --flake .#violet
```

```
# 個別のハッシュを得るときは nix-prefetch-github を使うといいらしい
nix-shell -p nix-prefetch-github --run "nix-prefetch-github kijimad xruler --rev <COMMIT_SHA>"
```

## 仮想イメージで試す手順

```shell
apt install -y qemu-kvm
```

```shell
# 1. 空のディスクイメージを作成:
qemu-img create -f qcow2 ubuntu.qcow2 100G

# 2. ISOからインストール:
qemu-system-x86_64 \
  -enable-kvm -m 4096 \
  -hda mint.qcow2 \
  -cdrom linuxmint-22.2-cinnamon-64bit.iso \
  -boot d

# 3. ISOなしで起動する:
qemu-system-x86_64 -enable-kvm -m 4096 -hda mint.qcow2
```
