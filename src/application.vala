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
}
