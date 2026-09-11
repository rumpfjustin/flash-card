/** A row in the deck list: deck name plus a live card count. */
public class FlashCard.DeckRow : Adw.ActionRow {

    public Deck deck { get; construct; }

    private ulong count_handler;

    public DeckRow (Deck deck) {
        Object (deck: deck);
    }

    construct {
        this.activatable = true;
        this.use_markup = false;

        deck.bind_property ("name", this, "title", BindingFlags.SYNC_CREATE);

        update_subtitle ();
        count_handler = deck.cards.items_changed.connect ((position, removed, added) => {
            update_subtitle ();
        });
        this.destroy.connect (() => {
            deck.cards.disconnect (count_handler);
        });

        this.add_suffix (new Gtk.Image.from_icon_name ("go-next-symbolic"));
    }

    private void update_subtitle () {
        uint n = deck.cards.get_n_items ();
        this.subtitle = n == 1 ? "1 card" : "%u cards".printf (n);
    }
}
