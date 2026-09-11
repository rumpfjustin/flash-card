/**
 * Loads, saves and tracks all decks.
 *
 * Decks live as individual JSON files under
 *   $XDG_DATA_HOME/flash-card/decks/            (usually ~/.local/share/...)
 *
 * The `decks` list is a {@link GLib.ListStore} of {@link FlashCard.Deck}, kept
 * sorted by name, so the main window can bind to it directly.
 */
public class FlashCard.DeckManager : GLib.Object {

    public GLib.ListStore decks { get; private set; }

    private File decks_dir;

    construct {
        decks = new GLib.ListStore (typeof (Deck));
        decks_dir = File.new_build_filename (
            Environment.get_user_data_dir (), "flash-card", "decks"
        );
    }

    /** Read every *.json file in the decks directory into `decks`. */
    public void load () {
        try {
            if (!decks_dir.query_exists ()) {
                decks_dir.make_directory_with_parents ();
                return;
            }

            var enumerator = decks_dir.enumerate_children (
                FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE,
                FileQueryInfoFlags.NONE
            );

            FileInfo info;
            while ((info = enumerator.next_file ()) != null) {
                if (info.get_file_type () != FileType.REGULAR) {
                    continue;
                }
                var name = info.get_name ();
                if (!name.has_suffix (".json")) {
                    continue;
                }

                try {
                    decks.append (parse_deck (decks_dir.get_child (name)));
                } catch (Error e) {
                    warning ("Skipping unreadable deck '%s': %s", name, e.message);
                }
            }

            sort_decks ();
        } catch (Error e) {
            warning ("Could not read decks directory: %s", e.message);
        }
    }

    /** Create a new empty deck, write it to disk and add it to `decks`. */
    public Deck create_deck (string name) throws Error {
        ensure_dir ();
        var deck = new Deck (name, unique_filename (name));
        save_deck (deck);
        decks.append (deck);
        sort_decks ();
        return deck;
    }

    /** Write a deck to its JSON file (pretty-printed). */
    public void save_deck (Deck deck) throws Error {
        ensure_dir ();

        var builder = new Json.Builder ();
        builder.begin_object ();

        builder.set_member_name ("name");
        builder.add_string_value (deck.name);

        builder.set_member_name ("cards");
        builder.begin_array ();
        for (uint i = 0; i < deck.cards.get_n_items (); i++) {
            var card = (Card) deck.cards.get_item (i);
            builder.begin_object ();
            builder.set_member_name ("front");
            builder.add_string_value (card.front);
            builder.set_member_name ("back");
            builder.add_string_value (card.back);
            builder.end_object ();
        }
        builder.end_array ();

        builder.end_object ();

        var generator = new Json.Generator ();
        generator.set_root (builder.get_root ());
        generator.pretty = true;
        generator.indent = 2;
        generator.to_file (decks_dir.get_child (deck.filename).get_path ());
    }

    /** Delete a deck's file and remove it from `decks`. */
    public void delete_deck (Deck deck) {
        try {
            var file = decks_dir.get_child (deck.filename);
            if (file.query_exists ()) {
                file.delete ();
            }
        } catch (Error e) {
            warning ("Could not delete deck file '%s': %s", deck.filename, e.message);
        }

        uint position;
        if (decks.find (deck, out position)) {
            decks.remove (position);
        }
    }

    private Deck parse_deck (File file) throws Error {
        var parser = new Json.Parser ();
        parser.load_from_file (file.get_path ());

        var root = parser.get_root ();
        if (root == null || root.get_node_type () != Json.NodeType.OBJECT) {
            throw new IOError.INVALID_DATA ("deck file is not a JSON object");
        }

        var obj = root.get_object ();
        var name = obj.get_string_member_with_default ("name", file.get_basename ());
        var deck = new Deck (name, file.get_basename ());

        if (obj.has_member ("cards")) {
            foreach (unowned Json.Node node in obj.get_array_member ("cards").get_elements ()) {
                if (node.get_node_type () != Json.NodeType.OBJECT) {
                    continue;
                }
                var card = node.get_object ();
                deck.add_card (new Card (
                    card.get_string_member_with_default ("front", ""),
                    card.get_string_member_with_default ("back", "")
                ));
            }
        }

        return deck;
    }

    private void sort_decks () {
        decks.sort ((a, b) => {
            return ((Deck) a).name.collate (((Deck) b).name);
        });
    }

    private void ensure_dir () throws Error {
        if (!decks_dir.query_exists ()) {
            decks_dir.make_directory_with_parents ();
        }
    }

    private string unique_filename (string deck_name) {
        var slug = slugify (deck_name);
        if (slug == "") {
            slug = "deck";
        }

        var candidate = slug + ".json";
        int suffix = 2;
        while (decks_dir.get_child (candidate).query_exists ()) {
            candidate = "%s-%d.json".printf (slug, suffix);
            suffix++;
        }
        return candidate;
    }

    private static string slugify (string input) {
        var builder = new StringBuilder ();
        int index = 0;
        unichar c;

        while (input.down ().get_next_char (ref index, out c)) {
            if (c < 128 && c.isalnum ()) {
                builder.append_unichar (c);
            } else if (c == ' ' || c == '-' || c == '_') {
                builder.append_c ('-');
            }
        }

        // Collapse runs of '-' and trim leading/trailing ones.
        var cleaned = new StringBuilder ();
        foreach (var part in builder.str.split ("-")) {
            if (part == "") {
                continue;
            }
            if (cleaned.len > 0) {
                cleaned.append_c ('-');
            }
            cleaned.append (part);
        }
        return cleaned.str;
    }
}
