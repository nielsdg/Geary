/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-edit-pane.ui")]
public class AccountEditPane : Gtk.Box {

    private Geary.AccountInformation account;

    // General
    [GtkChild]
    private Gtk.Label account_name_value;
    // Sender addresses
    [GtkChild]
    private Gtk.ListBox sender_addresses_list;
    // Composer
    [GtkChild]
    private Gtk.ListBoxRow signature_row;
    [GtkChild]
    private Gtk.Label signature_value;
    [GtkChild]
    private Gtk.Switch save_drafts_on_server_switch;
    // Mail server
    [GtkChild]
    private Gtk.ListBoxRow imap_server_row;
    [GtkChild]
    private Gtk.Label imap_server_value;
    [GtkChild]
    private Gtk.Label smtp_server_value;

    public AccountEditPane(Geary.AccountInformation account) {
        this.account = account;

        // General
        account_name_value.label = account.display_name;

        // Sender addresses
        sender_addresses_list.set_sort_func(sender_address_row_compare);
        refill_sender_addresses();

        // Composer
        account.bind_property("email-signature", signature_value, "label", BindingFlags.SYNC_CREATE,
            (binding, source_value, ref target_value) => {
                string signature = Geary.String.reduce_whitespace(source_value.get_string());
                target_value = (signature.length <= 30) ? signature : (signature.substring(0, 30) + "...");
                return true;
            });
        save_drafts_on_server_switch.active = account.save_drafts;
        save_drafts_on_server_switch.notify["active"].connect((spec) => {
            account.save_drafts = save_drafts_on_server_switch.active;
            account.store_async.begin();
        });

        // Mail server
        if (account.service_provider == Geary.ServiceProvider.OTHER) {
            imap_server_value.label = account.get_imap_endpoint().remote_address.hostname;
            smtp_server_value.label = account.get_smtp_endpoint().remote_address.hostname;
        } else {
            imap_server_value.label = account.service_provider.display_name();
            smtp_server_value.label = account.service_provider.display_name();
        }
    }

    private void refill_sender_addresses() {
        // delete each row except the add-row
        sender_addresses_list.foreach((row) => {
            if (row.get_data<Geary.RFC822.MailboxAddress>("mailboxAddress") != null)
                sender_addresses_list.remove(row);
        });

        foreach (Geary.RFC822.MailboxAddress mailbox in account.get_all_mailboxes())
            sender_addresses_list.add(build_sender_address_row(mailbox));

        sender_addresses_list.invalidate_sort();
    }

    private Gtk.ListBoxRow build_sender_address_row(Geary.RFC822.MailboxAddress mailboxAddress) {
        Gtk.ListBoxRow row = new Gtk.ListBoxRow();
        row.set_size_request(-1, 40);
        row.can_focus = false;
        row.set_data("mailboxAddress", mailboxAddress);
        Gtk.Box rowContainer = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        row.add(rowContainer);

        Gtk.Label label = new Gtk.Label(mailboxAddress.get_full_address());
        label.set_halign(Gtk.Align.START);
        label.set_hexpand(true);
        rowContainer.add(label);

        if (account.primary_mailbox.equal_to(mailboxAddress)) {
            Gtk.Label primaryLabel = new Gtk.Label("Primary");
            primaryLabel.get_style_context().add_class("dim-label");
            primaryLabel.set_halign(Gtk.Align.END);
            rowContainer.add(primaryLabel);
        } else {
            Gtk.Button removeAddressButton = new Gtk.Button.from_icon_name("list-remove-symbolic");
            removeAddressButton.get_style_context().add_class("flat");
            removeAddressButton.set_halign(Gtk.Align.END);
            removeAddressButton.clicked.connect((button) => {
                account.alternate_mailboxes.remove(mailboxAddress);
                account.store_async.begin();
                refill_sender_addresses();
            });
            rowContainer.add(removeAddressButton);
        }

        row.show_all();
        return row;
    }

    private int sender_address_row_compare(Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        Geary.RFC822.MailboxAddress mailboxAddress1
            = row1.get_data<Geary.RFC822.MailboxAddress>("mailboxAddress");
        Geary.RFC822.MailboxAddress mailboxAddress2
            = row2.get_data<Geary.RFC822.MailboxAddress>("mailboxAddress");

        // Check for the add-mailbox row
        if (mailboxAddress1 == null)
            return 1;
        if (mailboxAddress2 == null)
            return -1;

        // Primary email address should always be at the front
        if (account.primary_mailbox.equal_to(mailboxAddress1))
            return -1;
        if (account.primary_mailbox.equal_to(mailboxAddress2))
            return 1;

        // Neither is primary, sort alphabetically
        return (mailboxAddress1.get_full_address() >= mailboxAddress2.get_full_address()) ? 1 : -1;
    }

    [GtkCallback]
    private void on_sender_address_row_activated(Gtk.ListBoxRow row) {
        Geary.RFC822.MailboxAddress mailboxAddress
            = row.get_data<Geary.RFC822.MailboxAddress>("mailboxAddress");

        AccountAliasForm form = new AccountAliasForm(account, mailboxAddress);
        form.saved.connect(() => refill_sender_addresses());
        show_preference_dialog(form);
    }

    [GtkCallback]
    private void on_signature_row_activated(Gtk.ListBoxRow row) {
        if (row == signature_row)
            show_preference_dialog(new AccountSignatureForm(account));
    }

    [GtkCallback]
    private void on_category_server_list_row_activated(Gtk.ListBoxRow row) {
        if (row == imap_server_row)
            show_preference_dialog(new AccountImapForm(account));
        else
            show_preference_dialog(new AccountSmtpForm(account));
    }

    private void show_preference_dialog(AccountForm form) {
        Gtk.Dialog preferenceDialog = new Gtk.Dialog.with_buttons(
            form.title,
            (Gtk.Window)get_toplevel(),
            Gtk.DialogFlags.MODAL | Gtk.DialogFlags.USE_HEADER_BAR,
            _("Cancel"), Gtk.ResponseType.CANCEL
        );
        Gtk.Button applyButton = (Gtk.Button) preferenceDialog.add_button(_("Save"), Gtk.ResponseType.APPLY);
        applyButton.get_style_context().add_class("suggested-action");
        applyButton.sensitive = form.is_valid();
        form.validation_done.connect((succ) => applyButton.set_sensitive(succ));

        preferenceDialog.get_content_area().add(form);

        int response = preferenceDialog.run();
        switch (response) {
          case Gtk.ResponseType.APPLY:
              if (form.save())
                  account.store_async.begin();
              break;
          case Gtk.ResponseType.CANCEL:
          default:
              break;
        }

        preferenceDialog.destroy();
    }
}

