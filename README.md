# Flash Cards

A small GNOME desktop app for studying with two-sided flash cards, written in
**Vala** with **GTK 4** and **Libadwaita**.

- Create any number of **decks**, each with its own name.
- Add, edit and delete **cards** (a front and a back) within a deck.
- **Test yourself**: the app draws a random card, shows the front, and reveals
  the back when you ask. Press <kbd>Space</kbd> / <kbd>Enter</kbd> to advance.
- Every deck is stored as a plain **JSON file**, so decks are easy to back up,
  sync or edit by hand.

## Where decks are stored

```
$XDG_DATA_HOME/flash-card/decks/<deck-name>.json
```

which is normally `~/.local/share/flash-card/decks/`.

Each file looks like:

```json
{
  "name": "Spanish Verbs",
  "cards": [
    { "front": "to be (permanent)", "back": "ser" },
    { "front": "to be (temporary)", "back": "estar" }
  ]
}
```

## Building from source

Requires `valac`, `meson`, `ninja`, and the GTK 4, Libadwaita (≥ 1.5) and
json-glib (≥ 1.6) development packages.

```sh
meson setup build
meson compile -C build
./build/src/flash-card            # run without installing

sudo meson install -C build       # install system-wide
```

Or just run `./run.sh`, which does the setup/compile/launch steps above.

### Debian / Ubuntu package

Build a `.deb` from a checkout:

```sh
sudo apt build-dep .              # or install the Build-Depends from debian/control
dpkg-buildpackage -us -uc -b
sudo apt install ../flash-card_0.1.0_*.deb
```

Or just run `./build-deb.sh`, which does the same and collects the resulting
`.deb` files into `dist/`:

```sh
./build-deb.sh
sudo apt install dist/flash-card_0.1.0_*.deb
```

## License

MIT — see [LICENSE](LICENSE).
