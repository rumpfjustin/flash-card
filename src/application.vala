public class FlashCard.Application : Adw.Application {

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    construct {
        ActionEntry[] action_entries = {
            { "about", this.on_about_action },
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

    private void on_about_action () {
        var about = new Adw.AboutDialog () {
            application_name = Config.APP_NAME,
            application_icon = Config.APP_ID,
            developer_name = "Justin Rumpf",
            version = Config.VERSION,
            copyright = "© 2026 Justin Rumpf",
            license_type = Gtk.License.MIT_X11,
            website = "https://github.com/rumpfjustin/flash-card",
            issue_url = "https://github.com/rumpfjustin/flash-card/issues"
        };
        about.present (this.active_window);
    }

    private void on_quit_action () {
        this.quit ();
    }
}
