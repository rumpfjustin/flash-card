/**
 * A row in the deck list: deck name, a live card count, and buttons for the
 * actions that used to require opening the deck first.
 */
public class FlashCard.DeckRow : Adw.ActionRow {

    public Deck deck { get; construct; }

    public signal void test_requested ();
    public signal void rename_requested ();
    public signal void open_requested ();
    public signal void delete_requested ();

    private ulong count_handler;

    public DeckRow (Deck deck) {
        Object (deck: deck);
    }

    construct {
        this.use_markup = false;

        deck.bind_property ("name", this, "title", BindingFlags.SYNC_CREATE);

        update_subtitle ();
        count_handler = deck.cards.items_changed.connect ((position, removed, added) => {
            update_subtitle ();
        });
        this.destroy.connect (() => {
            deck.cards.disconnect (count_handler);
        });

        var test_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic") {
            valign = Gtk.Align.CENTER,
            tooltip_text = "Test",
            css_classes = { "flat" }
        };
        test_button.clicked.connect (() => test_requested ());

        var rename_button = new Gtk.Button.from_icon_name ("document-edit-symbolic") {
            valign = Gtk.Align.CENTER,
            tooltip_text = "Rename Deck",
            css_classes = { "flat" }
        };
        rename_button.clicked.connect (() => rename_requested ());

        var open_button = new Gtk.Button.from_icon_name ("go-next-symbolic") {
            valign = Gtk.Align.CENTER,
            tooltip_text = "Add or Edit Cards",
            css_classes = { "flat" }
        };
        open_button.clicked.connect (() => open_requested ());

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            valign = Gtk.Align.CENTER,
            tooltip_text = "Delete Deck",
            css_classes = { "flat" }
        };
        delete_button.clicked.connect (() => delete_requested ());

        this.add_suffix (test_button);
        this.add_suffix (rename_button);
        this.add_suffix (open_button);
        this.add_suffix (delete_button);
    }

    private void update_subtitle () {
        uint n = deck.cards.get_n_items ();
        this.subtitle = n == 1 ? "1 card" : "%u cards".printf (n);
    }
}
