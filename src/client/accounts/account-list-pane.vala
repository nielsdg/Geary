/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-list-pane.ui")]
public class AccountListPane : Gtk.Box {

    [GtkChild]
    private Gtk.ListBox account_list;

    public signal void account_edit(Geary.AccountInformation account);

    public AccountListPane() {
        account_list.set_sort_func(row_compare);

        try {
            foreach (Geary.AccountInformation account in Geary.Engine.instance.get_accounts().values)
                on_account_added(account);
        } catch (Error e) {
            debug("Error enumerating accounts: %s", e.message);
        }

        // Watch for accounts to be added/removed.
        Geary.Engine.instance.account_added.connect(on_account_added);
        Geary.Engine.instance.account_removed.connect(on_account_removed);
    }

    [GtkCallback]
    private void on_row_activated(Gtk.ListBoxRow row) {
        Geary.AccountInformation account = row.get_data<Geary.AccountInformation>("account");
        if (account == null) { // Add account-row
            var window = (Gtk.Window) get_toplevel();
            AccountCreateAssistant assistant = new AccountCreateAssistant(window);
            assistant.show();
            window.close();
        } else {
            account_edit(account);
        }
    }

    private void on_row_delete_button_activated(Gtk.ListBoxRow row) {
        // TODO
    }

    private void on_account_added(Geary.AccountInformation account) {
        if (contains_row(account.id))
            return;

        account_list.add(build_row(account));
        /* account.notify.connect(on_account_changed); */
        account_list.invalidate_sort();
        update_ordinals();
    }

    private Gtk.ListBoxRow build_row(Geary.AccountInformation account) {
        Gtk.ListBoxRow row = new Gtk.ListBoxRow();
        row.set_data("account", account);
        Gtk.Box rowContainer = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        row.add(rowContainer);

        Gtk.Label label = new Gtk.Label(account.display_name);
        label.set_halign(Gtk.Align.START);
        label.set_hexpand(true);
        rowContainer.add(label);

        Gtk.Button deleteButton = new Gtk.Button.from_icon_name("list-remove-symbolic");
        deleteButton.get_style_context().add_class("flat");
        deleteButton.activate.connect(() => on_row_delete_button_activated(row));
        rowContainer.add(deleteButton);

        row.show_all();

        return row;
    }

    private void on_account_removed(Geary.AccountInformation account) {
        Gtk.ListBoxRow row = get_row(account.id);
        if (row == null)
            return;

        account_list.remove(row);
        account.notify.disconnect(on_account_changed);
        update_ordinals();
    }

    private void on_account_changed(Object object, ParamSpec p) {
        Geary.AccountInformation account = (Geary.AccountInformation) object;

        Gtk.ListBoxRow row = get_row(account.id);
        if (row == null)
            return;

        ((Gtk.Label) row.get_children().nth_data(0)).label = account.nickname;
    }

    // Returns whether our account list contains an account with the given id.
    private bool contains_row(string id) {
        return get_row(id) != null;
    }

    // Returns the row of the account with given id, or null if it wasn't found.
    private Gtk.ListBoxRow? get_row(string id) {
        Gtk.ListBoxRow result = null;
        account_list.foreach((row) => {
            Geary.AccountInformation account = row.get_data<Geary.AccountInformation>("account");
            if ((account != null) && (account.id == id))
                result = row as Gtk.ListBoxRow;
        });
        return result;
    }

    // Call this to update ordinals when rows are added or removed.
    private void update_ordinals() {
        int i = 0;
        account_list.foreach((row) => {
            Geary.AccountInformation account = row.get_data<Geary.AccountInformation>("account");

            // To prevent unnecessary work, only set ordinal if there's a change.
            if ((account != null) && (i != account.ordinal)) {
                account.ordinal = i;
                account.store_async.begin(null);
            }

            i++;
        });
    }

    private int row_compare(Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        Geary.AccountInformation account1 = row1.get_data<Geary.AccountInformation>("account");
        Geary.AccountInformation account2 = row2.get_data<Geary.AccountInformation>("account");

        if (account1 == null)
            return 1;
        if (account2 == null)
            return -1;
        return Geary.AccountInformation.compare_ascending(account1, account2);
    }
}

