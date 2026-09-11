public class FlashCard.Window : Adw.ApplicationWindow {

    private DeckManager manager;
    private Adw.NavigationView nav_view;
    private Adw.ToastOverlay toast_overlay;
    private Gtk.Stack decks_stack;

    public Window (Adw.Application app) {
        Object (application: app);
    }

    construct {
        this.title = "Flash Cards";
        this.set_default_size (420, 640);
        this.width_request = 320;
        this.height_request = 400;

        manager = new DeckManager ();

        nav_view = new Adw.NavigationView ();
        nav_view.push (build_decks_page ());

        toast_overlay = new Adw.ToastOverlay () {
            child = nav_view
        };
        this.content = toast_overlay;

        manager.load ();
        update_decks_visibility ();
    }

    /* ---------------------------------------------------------------------
     * Deck list page
     * ------------------------------------------------------------------ */

    private Adw.NavigationPage build_decks_page () {
        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = "New Deck"
        };
        add_button.clicked.connect (add_deck);

        var header = new Adw.HeaderBar ();
        header.pack_end (add_button);

        var empty_button = new Gtk.Button.with_label ("New Deck") {
            halign = Gtk.Align.CENTER,
            css_classes = { "pill", "suggested-action" }
        };
        empty_button.clicked.connect (add_deck);

        var empty_page = new Adw.StatusPage () {
            icon_name = "view-list-symbolic",
            title = "No Decks",
            description = "Create a deck to start adding flash cards.",
            child = empty_button
        };

        var deck_flow = new Gtk.FlowBox () {
            selection_mode = Gtk.SelectionMode.NONE,
            homogeneous = false,
            row_spacing = 8,
            column_spacing = 8,
            valign = Gtk.Align.START,
            halign = Gtk.Align.FILL
        };
        deck_flow.bind_model (manager.decks, (item) => {
            var deck = (Deck) item;
            var chip = new DeckChip (deck);
            chip.test_requested.connect (() => start_test (deck));
            chip.edit_requested.connect (() => open_deck (deck));
            chip.delete_requested.connect (() => confirm_delete_deck (deck));
            return chip;
        });

        var list_page = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            child = new Adw.Clamp () {
                maximum_size = 520,
                child = deck_flow,
                margin_top = 12,
                margin_bottom = 12,
                margin_start = 12,
                margin_end = 12
            }
        };

        decks_stack = new Gtk.Stack ();
        decks_stack.add_named (empty_page, "empty");
        decks_stack.add_named (list_page, "list");

        manager.decks.items_changed.connect ((position, removed, added) => {
            update_decks_visibility ();
        });

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (header);
        toolbar_view.content = decks_stack;

        var page = new Adw.NavigationPage (toolbar_view, "Flash Cards");
        page.tag = "decks";
        return page;
    }

    private void update_decks_visibility () {
        decks_stack.visible_child_name =
            manager.decks.get_n_items () > 0 ? "list" : "empty";
    }

    /* ---------------------------------------------------------------------
     * Single deck page
     * ------------------------------------------------------------------ */

    private void open_deck (Deck deck) {
        nav_view.push (build_deck_page (deck));
    }

    private void start_test (Deck deck) {
        if (deck.cards.get_n_items () == 0) {
            notify_user ("Add a card before testing");
            return;
        }
        nav_view.push (new TestPage (deck));
    }

    private Adw.NavigationPage build_deck_page (Deck deck) {
        var add_card_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = "Add Card"
        };
        add_card_button.clicked.connect (() => edit_card (deck, null));

        var test_button = new Gtk.Button.with_label ("Test") {
            tooltip_text = "Draw random cards and quiz yourself",
            css_classes = { "suggested-action" }
        };
        test_button.clicked.connect (() => start_test (deck));

        var deck_actions = new GLib.SimpleActionGroup ();
        var rename_action = new GLib.SimpleAction ("rename", null);
        rename_action.activate.connect (() => rename_deck (deck));
        deck_actions.add_action (rename_action);
        var delete_action = new GLib.SimpleAction ("delete", null);
        delete_action.activate.connect (() => confirm_delete_deck (deck));
        deck_actions.add_action (delete_action);

        var deck_menu = new GLib.Menu ();
        deck_menu.append ("Rename Deck…", "deck.rename");
        deck_menu.append ("Delete Deck…", "deck.delete");

        var menu_button = new Gtk.MenuButton () {
            icon_name = "view-more-symbolic",
            tooltip_text = "Deck Options",
            menu_model = deck_menu
        };

        var header = new Adw.HeaderBar ();
        header.pack_start (add_card_button);
        header.pack_end (menu_button);
        header.pack_end (test_button);

        var empty_button = new Gtk.Button.with_label ("Add Card") {
            halign = Gtk.Align.CENTER,
            css_classes = { "pill", "suggested-action" }
        };
        empty_button.clicked.connect (() => edit_card (deck, null));

        var empty_page = new Adw.StatusPage () {
            icon_name = "document-new-symbolic",
            title = "No Cards",
            description = "Add a card with a front and a back.",
            child = empty_button
        };

        var card_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE,
            css_classes = { "boxed-list" }
        };
        card_list.row_activated.connect ((row) => {
            edit_card (deck, ((CardRow) row).card);
        });
        card_list.bind_model (deck.cards, (item) => {
            var row = new CardRow ((Card) item);
            row.delete_requested.connect (() => delete_card (deck, row.card));
            return row;
        });

        var list_page = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            child = new Adw.Clamp () {
                maximum_size = 520,
                child = card_list,
                margin_top = 12,
                margin_bottom = 12,
                margin_start = 12,
                margin_end = 12
            }
        };

        var stack = new Gtk.Stack ();
        stack.add_named (empty_page, "empty");
        stack.add_named (list_page, "list");
        stack.visible_child_name = deck.cards.get_n_items () > 0 ? "list" : "empty";

        var visibility_handler = deck.cards.items_changed.connect ((position, removed, added) => {
            stack.visible_child_name = deck.cards.get_n_items () > 0 ? "list" : "empty";
        });

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (header);
        toolbar_view.content = stack;

        var page = new Adw.NavigationPage (toolbar_view, deck.name);
        deck.bind_property ("name", page, "title", BindingFlags.SYNC_CREATE);
        page.insert_action_group ("deck", deck_actions);
        page.destroy.connect (() => {
            deck.cards.disconnect (visibility_handler);
        });
        return page;
    }

    /* ---------------------------------------------------------------------
     * Deck create / rename / delete
     * ------------------------------------------------------------------ */

    private void add_deck () {
        var entry = new Gtk.Entry () {
            placeholder_text = "Deck name",
            activates_default = true
        };

        var dialog = new Adw.AlertDialog ("New Deck", null);
        dialog.set_extra_child (entry);
        dialog.add_response ("cancel", "Cancel");
        dialog.add_response ("create", "Create");
        dialog.set_response_appearance ("create", Adw.ResponseAppearance.SUGGESTED);
        dialog.set_default_response ("create");
        dialog.set_close_response ("cancel");

        dialog.response.connect ((response) => {
            if (response != "create") {
                return;
            }
            var name = entry.text.strip ();
            if (name == "") {
                notify_user ("Deck name cannot be empty");
                return;
            }
            try {
                open_deck (manager.create_deck (name));
            } catch (Error e) {
                notify_user ("Could not create deck: %s".printf (e.message));
            }
        });

        dialog.present (this);
        entry.grab_focus ();
    }

    private void rename_deck (Deck deck) {
        var entry = new Gtk.Entry () {
            text = deck.name,
            activates_default = true
        };

        var dialog = new Adw.AlertDialog ("Rename Deck", null);
        dialog.set_extra_child (entry);
        dialog.add_response ("cancel", "Cancel");
        dialog.add_response ("rename", "Rename");
        dialog.set_response_appearance ("rename", Adw.ResponseAppearance.SUGGESTED);
        dialog.set_default_response ("rename");
        dialog.set_close_response ("cancel");

        dialog.response.connect ((response) => {
            if (response != "rename") {
                return;
            }
            var name = entry.text.strip ();
            if (name == "") {
                notify_user ("Deck name cannot be empty");
                return;
            }
            deck.name = name;
            persist (deck);
        });

        dialog.present (this);
        entry.grab_focus ();
    }

    private void confirm_delete_deck (Deck deck) {
        var dialog = new Adw.AlertDialog (
            "Delete “%s”?".printf (GLib.Markup.escape_text (deck.name)),
            "This permanently removes the deck file and its %u card(s).".printf (
                deck.cards.get_n_items ())
        );
        dialog.add_response ("cancel", "Cancel");
        dialog.add_response ("delete", "Delete");
        dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);
        dialog.set_default_response ("cancel");
        dialog.set_close_response ("cancel");

        dialog.response.connect ((response) => {
            if (response != "delete") {
                return;
            }
            manager.delete_deck (deck);
            nav_view.pop_to_tag ("decks");
            notify_user ("Deck deleted");
        });

        dialog.present (this);
    }

    /* ---------------------------------------------------------------------
     * Card add / edit / delete
     * ------------------------------------------------------------------ */

    private void edit_card (Deck deck, Card? card) {
        var front_row = new Adw.EntryRow () { title = "Front" };
        var back_row = new Adw.EntryRow () { title = "Back" };
        if (card != null) {
            front_row.text = card.front;
            back_row.text = card.back;
        }

        var group = new Adw.PreferencesGroup ();
        group.add (front_row);
        group.add (back_row);

        var cancel_button = new Gtk.Button.with_label ("Cancel");
        var save_button = new Gtk.Button.with_label ("Save") {
            css_classes = { "suggested-action" }
        };

        var header = new Adw.HeaderBar () {
            show_start_title_buttons = false,
            show_end_title_buttons = false
        };
        header.pack_start (cancel_button);
        header.pack_end (save_button);

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (header);
        toolbar_view.content = new Adw.Clamp () {
            maximum_size = 400,
            child = group,
            margin_top = 18,
            margin_bottom = 18,
            margin_start = 12,
            margin_end = 12
        };

        var dialog = new Adw.Dialog () {
            title = card == null ? "Add Card" : "Edit Card",
            content_width = 420,
            child = toolbar_view
        };

        cancel_button.clicked.connect (() => dialog.close ());
        save_button.clicked.connect (() => {
            var front = front_row.text.strip ();
            var back = back_row.text.strip ();
            if (front == "" && back == "") {
                dialog.close ();
                return;
            }
            if (card == null) {
                deck.add_card (new Card (front, back));
            } else {
                card.front = front;
                card.back = back;
            }
            persist (deck);
            dialog.close ();
        });

        dialog.present (this);
        front_row.grab_focus ();
    }

    private void delete_card (Deck deck, Card card) {
        uint position;
        if (!deck.cards.find (card, out position)) {
            return;
        }
        deck.cards.remove (position);
        persist (deck);

        var toast = new Adw.Toast ("Card deleted") {
            button_label = "Undo",
            use_markup = false
        };
        toast.button_clicked.connect (() => {
            deck.cards.insert (position, card);
            persist (deck);
        });
        toast_overlay.add_toast (toast);
    }

    /* ---------------------------------------------------------------------
     * Helpers
     * ------------------------------------------------------------------ */

    private void persist (Deck deck) {
        try {
            manager.save_deck (deck);
        } catch (Error e) {
            notify_user ("Could not save deck: %s".printf (e.message));
        }
    }

    private void notify_user (string message) {
        toast_overlay.add_toast (new Adw.Toast (message) { use_markup = false });
    }
}
