# KH Re:Chain Intel Arc video fix

An unofficial, experimental workaround for **Kingdom Hearts Re:Chain of Memories** on **Windows with Intel Arc graphics**. It is part of the *Kingdom Hearts HD 1.5+2.5 ReMIX* collection on Steam.

On affected systems, scenes are black or badly lit, and the pre-rendered voice-acted videos can stay black while their audio plays. This project combines patched builds of [DXVK](https://github.com/doitsujin/dxvk) and [vkd3d-proton](https://github.com/HansKristian-Work/vkd3d-proton) so that gameplay, text-box scenes and videos all render.

This project is not affiliated with or endorsed by Square Enix, Disney, Intel, or the DXVK or vkd3d-proton projects. Please don't report problems with these builds to those projects.

## Tested on

| Item | Version |
| --- | --- |
| GPU | Intel Arc 140V |
| Graphics driver | 32.0.101.9150 |
| OS | Windows 11 |
| Game | Steam version |
| DXVK | v3.1.1 |
| vkd3d-proton | v3.1 |

This has only been tested on that one setup, mainly through the intro scenes. It may not work on other Arc GPUs or drivers, and a driver update could break it. Reports from other systems are welcome: please open an issue with your GPU, driver version and result.

Only use this for Re:Chain. It changes how shared textures work, so don't use these DLLs with other games.

## Install

1. Download the DLLs from the [Releases](../../releases) page, or build them yourself.
2. Copy `d3d11.dll`, `dxgi.dll`, `d3d12.dll` and `d3d12core.dll` into the game folder, next to `KINGDOM HEARTS Re_Chain of Memories.exe`. The default location is:

   ```
   C:\Program Files (x86)\Steam\steamapps\common\KINGDOM HEARTS -HD 1.5+2.5 ReMIX-
   ```

3. In Steam, right-click the game, open **Properties**, and paste this into **Launch Options**. Change the path if your game is installed somewhere else.

   ```
   "C:\Program Files (x86)\Steam\steamapps\common\KINGDOM HEARTS -HD 1.5+2.5 ReMIX-\KINGDOM HEARTS Re_Chain of Memories.exe" %command%
   ```

4. Press Play. Re:Chain starts directly because the launcher crashes when these DLLs are installed.
5. In the game's settings, set the framerate to **Unlimited** and turn the refresh rate sync (V-Sync) setting **Off**.

## Uninstall, or play another game in the collection

1. Clear the launch option.
2. Delete or move the four DLLs out of the game folder.

## How it works

The game renders with D3D12 but decodes its videos through Media Foundation on a D3D11 device, then shares the NV12 video textures with D3D12. vkd3d-proton handles D3D12 and DXVK handles D3D11 and DXGI.

Stock builds can't share those textures on this setup:

- The game creates legacy shared textures, and the Intel Windows driver doesn't provide a usable KMT handle for them.
- DXVK and vkd3d-proton normally exchange texture details through a Proton-only device, `\\.\SharedGpuResource`, which doesn't exist on Windows.

The patches make these changes:

- **DXVK** exports legacy shared textures with an NT handle, keeps the first handle the driver returns, and duplicates it when needed.
- **DXVK** publishes the texture metadata in a process-local environment variable keyed on that handle.
- **vkd3d-proton** reads that metadata, imports the texture, and rejects NULL handles rather than creating a blank texture.

## Build from source

1. Install [MSYS2](https://www.msys2.org/).
2. In an MSYS2 terminal, install the build tools:

   ```
   pacman -S --needed git bison flex mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-glslang mingw-w64-ucrt-x86_64-spirv-tools mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-tools-git
   ```

3. From this repository, run:

   ```
   bash build.sh
   ```

The script downloads the matching upstream versions, applies the files in `patches/`, and puts the four DLLs in `dist/`.

## Licenses

- The DXVK patch and modified DXVK DLLs (`d3d11.dll`, `dxgi.dll`) are under the zlib/libpng license. See [LICENSES/DXVK-LICENSE](LICENSES/DXVK-LICENSE).
- The vkd3d-proton patch and modified vkd3d-proton DLLs (`d3d12.dll`, `d3d12core.dll`) are under the GNU LGPL 2.1. See [LICENSES/VKD3D-PROTON-LICENSE](LICENSES/VKD3D-PROTON-LICENSE).

The DLLs in Releases are modified versions, not the original upstream software. The complete changes are in `patches/`, and the upstream source is available at the tags listed above.

No game files are included in this repository or its releases.
