/**
 * A single two-sided flash card.
 *
 * Serialized inside a deck's JSON file as:
 *   { "front": "...", "back": "..." }
 */
public class FlashCard.Card : GLib.Object {

    public string front { get; set; default = ""; }
    public string back  { get; set; default = ""; }

    public Card (string front, string back) {
        Object (front: front, back: back);
    }
}
