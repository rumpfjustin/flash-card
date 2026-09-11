/**
 * A compact, pill-shaped entry for one deck in the deck list.
 *
 * Sized to its content (not stretched to the full row width) and tinted
 * with one of a handful of accent colors, chosen from a hash of the deck's
 * name, so decks stay visually distinct from one another.
 */
public class FlashCard.DeckChip : Gtk.Box {

    public Deck deck { get; construct; }

    public signal void test_requested ();
    public signal void edit_requested ();
    public signal void delete_requested ();

    private static string[] accent_classes = {
        "deck-chip-blue", "deck-chip-green", "deck-chip-yellow", "deck-chip-orange",
        "deck-chip-red", "deck-chip-purple", "deck-chip-pink", "deck-chip-teal"
    };

    private Gtk.Label subtitle_label;
    private ulong count_handler;

    public DeckChip (Deck deck) {
        Object (deck: deck, orientation: Gtk.Orientation.HORIZONTAL, spacing: 4);
    }

    construct {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this.add_css_class ("deck-chip");
        this.add_css_class (accent_classes[accent_index_for (deck.name)]);

        var text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            valign = Gtk.Align.CENTER,
            margin_start = 10,
            margin_end = 6
        };

        var name_label = new Gtk.Label (null) {
            xalign = 0,
            ellipsize = Pango.EllipsizeMode.END,
            max_width_chars = 22,
            css_classes = { "heading" }
        };
        deck.bind_property ("name", name_label, "label", BindingFlags.SYNC_CREATE);

        subtitle_label = new Gtk.Label (null) {
            xalign = 0,
            css_classes = { "caption", "dim-label" }
        };
        update_subtitle ();
        count_handler = deck.cards.items_changed.connect ((position, removed, added) => {
            update_subtitle ();
        });
        this.destroy.connect (() => deck.cards.disconnect (count_handler));

        text_box.append (name_label);
        text_box.append (subtitle_label);
        this.append (text_box);

        var test_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic") {
            tooltip_text = "Test",
            valign = Gtk.Align.CENTER,
            css_classes = { "flat", "circular" }
        };
        test_button.clicked.connect (() => test_requested ());

        var edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic") {
            tooltip_text = "Edit",
            valign = Gtk.Align.CENTER,
            css_classes = { "flat", "circular" }
        };
        edit_button.clicked.connect (() => edit_requested ());

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            tooltip_text = "Delete",
            valign = Gtk.Align.CENTER,
            css_classes = { "flat", "circular" }
        };
        delete_button.clicked.connect (() => delete_requested ());

        this.append (test_button);
        this.append (edit_button);
        this.append (delete_button);
    }

    private void update_subtitle () {
        uint n = deck.cards.get_n_items ();
        subtitle_label.label = n == 1 ? "1 card" : "%u cards".printf (n);
    }

    private static uint accent_index_for (string name) {
        uint hash = 5381;
        for (int i = 0; i < name.length; i++) {
            hash = ((hash << 5) + hash) + (uint) name[i];
        }
        return hash % accent_classes.length;
    }
}
