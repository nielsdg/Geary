/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-alias-form.ui")]
public class AccountAliasForm : AccountForm {
    [GtkChild]
    private Gtk.Entry name_value;
    [GtkChild]
    private Gtk.Entry email_value;
    [GtkChild]
    private Gtk.Button make_primary_button;

    public AccountAliasForm(Geary.AccountInformation account, Geary.RFC822.MailboxAddress? mailboxAddress) {
        base(account, _("Email Address"));

        if (mailboxAddress != null) {
            if (mailboxAddress.name != null)
                name_value.text = mailboxAddress.name;
            email_value.text = mailboxAddress.address;
        }

        make_primary_button.sensitive = !(mailboxAddress != null && account.primary_mailbox.equal_to(mailboxAddress));
    }

    public override bool is_valid() { //TODO
        return true;
    }
}
