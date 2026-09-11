#!/usr/bin/env bash
# Build a .deb package for Flash Cards via dpkg-buildpackage.
#
# Requires the packages listed in debian/control's Build-Depends. On
# Debian/Ubuntu you can install them with:
#   sudo apt build-dep .
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

dpkg-buildpackage -us -uc -b

echo
echo "Built packages:"
ls -1 ../flash-card_*.deb ../flash-card-dbgsym_*.deb 2>/dev/null
