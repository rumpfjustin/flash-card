#!/usr/bin/env bash
# Build a .deb package for Flash Cards via dpkg-buildpackage, and collect the
# resulting files into dist/.
#
# Requires the packages listed in debian/control's Build-Depends. On
# Debian/Ubuntu you can install them with:
#   sudo apt build-dep .
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

dist_dir="dist"
mkdir -p "$dist_dir"

# noautodbgsym skips debhelper's automatic -dbgsym debug symbols package.
DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:-} noautodbgsym" dpkg-buildpackage -us -uc -b

# dpkg-buildpackage always drops its output one directory up; move it into
# dist/ so build artifacts stay inside the project. Any leftover dbgsym
# package (e.g. from an older build) is discarded rather than moved.
shopt -s nullglob
rm -f ../flash-card-dbgsym_*.deb
built=(../flash-card_*.deb ../flash-card_*.buildinfo ../flash-card_*.changes)
if [ "${#built[@]}" -gt 0 ]; then
    mv -f "${built[@]}" "$dist_dir/"
fi

echo
echo "Built packages:"
ls -1 "$dist_dir"/flash-card_*.deb 2>/dev/null
