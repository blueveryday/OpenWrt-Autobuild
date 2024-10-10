#!/bin/bash

# Update source code
directories=(
  "immortalwrt"
  "immortalwrt_23"
  "immortalwrt_pkg"
  "immortalwrt_luci"
  "immortalwrt_luci_23"
  "lede"
  "lede_pkg"
  "lede_luci"
  "openwrt_ma"
  "openwrt_pkg_ma"
  "openwrt_luci_ma"
  "openwrt_app"
  "Lienol_pkg"
  "passwall_pkg"
)

for dir in "${directories[@]}"; do
  if [ -d "$dir/.git" ]; then
    echo "Updating $dir..."
    git -C "$dir" fetch --depth=1
    if [ $? -eq 0 ]; then
      echo "$dir has been updated successfully."
    else
      echo "Failed to update $dir."
    fi
  else
    echo "$dir is not a git repository."
  fi
done

exit 0