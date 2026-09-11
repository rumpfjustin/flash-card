/**
 * A named collection of flash cards.
 *
 * Each deck is backed by one JSON file (see {@link FlashCard.DeckManager}):
 *   { "name": "...", "cards": [ { "front": "...", "back": "..." }, ... ] }
 *
 * The `cards` list is a {@link GLib.ListStore} so views can bind to it directly
 * and update automatically as cards are added or removed.
 */
public class FlashCard.Deck : GLib.Object {

    public string name { get; set; default = ""; }

    /** Base name of the backing file, e.g. "spanish-verbs.json". */
    public string filename { get; set; default = ""; }

    public GLib.ListStore cards { get; private set; }

    construct {
        cards = new GLib.ListStore (typeof (Card));
    }

    public Deck (string name, string filename) {
        Object (name: name, filename: filename);
    }

    public void add_card (Card card) {
        cards.append (card);
    }

    public void remove_card (Card card) {
        uint position;
        if (cards.find (card, out position)) {
            cards.remove (position);
        }
    }

    /**
     * Return a random card from the deck, avoiding `previous` when the deck
     * has more than one card so the same card is not shown twice in a row.
     */
    public Card? random_card (Card? previous) {
        uint n = cards.get_n_items ();
        if (n == 0) {
            return null;
        }
        if (n == 1) {
            return (Card) cards.get_item (0);
        }

        Card? pick = null;
        do {
            uint index = GLib.Random.int_range (0, (int32) n);
            pick = (Card) cards.get_item (index);
        } while (pick == previous);

        return pick;
    }
}
