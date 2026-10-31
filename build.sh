#!/bin/bash
# Builds patched DXVK and vkd3d-proton with MSYS2 and puts the DLLs in dist/.
set -e

export PATH=/ucrt64/bin:/usr/bin:$PATH

DXVK_TAG=v3.1.1
VKD3D_TAG=v3.1
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="$ROOT/work"

mkdir -p "$WORK" "$ROOT/dist"

if [ ! -d "$WORK/dxvk" ]; then
  git clone --depth 1 --branch "$DXVK_TAG" --recurse-submodules --shallow-submodules \
    https://github.com/doitsujin/dxvk.git "$WORK/dxvk"
  git -C "$WORK/dxvk" apply --ignore-whitespace "$ROOT/patches/dxvk-kh-fix.patch"
fi

if [ ! -d "$WORK/vkd3d-proton" ]; then
  git clone --depth 1 --branch "$VKD3D_TAG" --recurse-submodules --shallow-submodules \
    https://github.com/HansKristian-Work/vkd3d-proton.git "$WORK/vkd3d-proton"
  git -C "$WORK/vkd3d-proton" apply --ignore-whitespace "$ROOT/patches/vkd3d-proton-kh-fix.patch"
fi

cd "$WORK/dxvk"
[ -f ../build-dxvk/build.ninja ] || meson setup ../build-dxvk --buildtype=release -Dstrip=true \
  -Denable_d3d8=false -Denable_d3d9=false -Denable_d3d10=false
ninja -C ../build-dxvk

cd "$WORK/vkd3d-proton"
[ -f ../build-vkd3d/build.ninja ] || meson setup ../build-vkd3d --buildtype=release -Dstrip=true
ninja -C ../build-vkd3d

cp "$WORK/build-dxvk/src/d3d11/d3d11.dll" "$WORK/build-dxvk/src/dxgi/dxgi.dll" "$ROOT/dist/"
find "$WORK/build-vkd3d" -name 'd3d12*.dll' -exec cp {} "$ROOT/dist/" \;

echo "Done. DLLs are in $ROOT/dist"
