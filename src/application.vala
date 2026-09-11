public class FlashCard.Application : Adw.Application {

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    construct {
        ActionEntry[] action_entries = {
            { "quit", this.on_quit_action },
        };
        this.add_action_entries (action_entries, this);
        this.set_accels_for_action ("app.quit", { "<primary>q" });
    }

    public override void startup () {
        base.startup ();
        load_styles ();
    }

    public override void activate () {
        base.activate ();

        var window = this.active_window;
        if (window == null) {
            window = new FlashCard.Window (this);
        }
        window.present ();
    }

    private void on_quit_action () {
        this.quit ();
    }

    /** Tints used for each deck's "chip" on the deck list; see DeckChip. */
    private void load_styles () {
        var provider = new Gtk.CssProvider ();
        provider.load_from_string ("""
            .deck-chip {
                border-radius: 999px;
                padding: 4px;
            }
            .deck-chip-blue   { background-color: alpha(#3584e4, 0.15); border: 1px solid alpha(#3584e4, 0.45); }
            .deck-chip-green  { background-color: alpha(#26a269, 0.15); border: 1px solid alpha(#26a269, 0.45); }
            .deck-chip-yellow { background-color: alpha(#e5a50a, 0.18); border: 1px solid alpha(#e5a50a, 0.5); }
            .deck-chip-orange { background-color: alpha(#e66100, 0.15); border: 1px solid alpha(#e66100, 0.45); }
            .deck-chip-red    { background-color: alpha(#e01b24, 0.15); border: 1px solid alpha(#e01b24, 0.45); }
            .deck-chip-purple { background-color: alpha(#9141ac, 0.15); border: 1px solid alpha(#9141ac, 0.45); }
            .deck-chip-pink   { background-color: alpha(#d56199, 0.15); border: 1px solid alpha(#d56199, 0.45); }
            .deck-chip-teal   { background-color: alpha(#0891b2, 0.15); border: 1px solid alpha(#0891b2, 0.45); }
        """);
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }
}
