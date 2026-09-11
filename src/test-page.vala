/**
 * Self-test view: draws a random card from the deck, shows its front, and
 * reveals the back on demand. The single action button toggles between
 * "Show Answer" and "Next Card".
 */
public class FlashCard.TestPage : Adw.NavigationPage {

    public Deck deck { get; construct; }

    private Gtk.Label question_label;
    private Gtk.Label answer_label;
    private Gtk.Revealer answer_revealer;
    private Gtk.Button action_button;

    private Card? current;
    private bool answer_shown;

    public TestPage (Deck deck) {
        Object (deck: deck);
    }

    construct {
        this.title = "Test: " + deck.name;
        this.child = build_ui ();
        install_shortcuts ();
        next_card ();
    }

    private Gtk.Widget build_ui () {
        question_label = new Gtk.Label ("") {
            wrap = true,
            justify = Gtk.Justification.CENTER,
            max_width_chars = 28,
            css_classes = { "title-1" }
        };

        answer_label = new Gtk.Label ("") {
            wrap = true,
            justify = Gtk.Justification.CENTER,
            max_width_chars = 28,
            css_classes = { "title-2" }
        };

        var answer_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        answer_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        answer_box.append (new Gtk.Label ("ANSWER") {
            css_classes = { "caption-heading", "dim-label" }
        });
        answer_box.append (answer_label);

        answer_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
            child = answer_box
        };

        var card_inner = new Gtk.Box (Gtk.Orientation.VERTICAL, 18) {
            valign = Gtk.Align.CENTER,
            margin_top = 36,
            margin_bottom = 36,
            margin_start = 24,
            margin_end = 24
        };
        card_inner.append (new Gtk.Label ("QUESTION") {
            css_classes = { "caption-heading", "dim-label" }
        });
        card_inner.append (question_label);
        card_inner.append (answer_revealer);

        var card = new Adw.Bin () {
            child = card_inner,
            css_classes = { "card" },
            valign = Gtk.Align.CENTER
        };

        var content = new Adw.Clamp () {
            maximum_size = 480,
            child = card,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 12,
            margin_end = 12
        };

        var scroller = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            child = content
        };

        action_button = new Gtk.Button.with_label ("Show Answer") {
            halign = Gtk.Align.CENTER,
            css_classes = { "pill", "suggested-action" }
        };
        action_button.clicked.connect (on_action_clicked);

        var bottom_bar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.CENTER,
            margin_top = 12,
            margin_bottom = 12
        };
        bottom_bar.append (action_button);

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (new Adw.HeaderBar ());
        toolbar_view.content = scroller;
        toolbar_view.add_bottom_bar (bottom_bar);
        return toolbar_view;
    }

    private void install_shortcuts () {
        var controller = new Gtk.ShortcutController ();
        controller.add_shortcut (new Gtk.Shortcut (
            Gtk.ShortcutTrigger.parse_string ("space|Return|KP_Enter"),
            new Gtk.CallbackAction ((widget, args) => {
                action_button.activate ();
                return true;
            })
        ));
        this.add_controller (controller);
    }

    private void on_action_clicked () {
        if (answer_shown) {
            next_card ();
        } else {
            answer_revealer.reveal_child = true;
            action_button.label = "Next Card";
            answer_shown = true;
        }
    }

    private void next_card () {
        current = deck.random_card (current);
        if (current == null) {
            return;
        }
        question_label.label = current.front;
        answer_label.label = current.back;
        answer_revealer.reveal_child = false;
        action_button.label = "Show Answer";
        answer_shown = false;
    }
}
