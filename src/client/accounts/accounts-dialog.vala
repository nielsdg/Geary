/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/accounts-dialog.ui")]
public class AccountsDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.HeaderBar headerbar;
    [GtkChild]
    private Gtk.Button back_button;
    [GtkChild]
    private Gtk.Separator back_button_separator;
    [GtkChild]
    private Gtk.Stack pages_stack;

    private AccountListPane list_pane = new AccountListPane();
    private AccountEditPane? edit_pane = null;

    public AccountsDialog(Gtk.Window parent) {
        Object(transient_for: parent, use_header_bar: 1);

        list_pane.account_edit.connect(on_account_edit);
        pages_stack.add(list_pane);

        headerbar.title = _("Accounts");
    }

    private void on_account_edit(Geary.AccountInformation account) {
        edit_pane = new AccountEditPane(account);
        pages_stack.add(edit_pane);
        pages_stack.visible_child = edit_pane;

        headerbar.set_title(account.display_name);
        headerbar.set_subtitle(account.service_provider.display_name());
        back_button.show();
        back_button_separator.show();
    }

    [GtkCallback]
    private void on_back_button_clicked() {
        pages_stack.visible_child = list_pane;
        pages_stack.remove(edit_pane);
        edit_pane = null;

        headerbar.title = _("Accounts");
        headerbar.subtitle = null;
        back_button.hide();
        back_button_separator.hide();
    }
}

