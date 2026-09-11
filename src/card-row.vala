/** A row in a deck's card list: front as title, back as subtitle, plus a delete button. */
public class FlashCard.CardRow : Adw.ActionRow {

    public Card card { get; construct; }

    /** Emitted when the row's delete button is clicked. */
    public signal void delete_requested ();

    public CardRow (Card card) {
        Object (card: card);
    }

    construct {
        this.activatable = true;
        this.use_markup = false;

        card.bind_property ("front", this, "title", BindingFlags.SYNC_CREATE);
        card.bind_property ("back", this, "subtitle", BindingFlags.SYNC_CREATE);

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            valign = Gtk.Align.CENTER,
            tooltip_text = "Delete Card",
            css_classes = { "flat" }
        };
        delete_button.clicked.connect (() => delete_requested ());

        this.add_suffix (delete_button);
        this.add_suffix (new Gtk.Image.from_icon_name ("document-edit-symbolic"));
    }
}
