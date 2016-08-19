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
    /* [GtkChild] */
    /* private Gtk.Label email_validation_label; */
    [GtkChild]
    private Gtk.Button make_primary_button;

    private Geary.RFC822.MailboxAddress? mailbox_address = null;

    /**
      * This signal is sent after the save() method has successfully validated and saved.
      */
    public signal void saved();

    public AccountAliasForm(Geary.AccountInformation account, Geary.RFC822.MailboxAddress? mailboxAddress) {
        base(account, _("Email Address"));

        Geary.EmailValidator email_validator = new Geary.EmailValidator();
        bind_validator(email_value, email_validator, "address");
        email_validator.validation_done.connect((succ, error_message) => {
            if (succ) {
                email_value.secondary_icon_name = null;
                email_value.secondary_icon_tooltip_text =  null;
            } else {
                email_value.secondary_icon_name = "dialog-warning-symbolic";
                email_value.secondary_icon_tooltip_text = error_message;
            }
        });

        if (mailboxAddress != null) {
            mailbox_address = mailboxAddress;
            email_value.text = mailboxAddress.address;

            if (mailboxAddress.name != null)
                name_value.text = mailboxAddress.name;
        }

        make_primary_button.sensitive = (mailboxAddress == null)
                                        || (!account.primary_mailbox.equal_to(mailboxAddress));
    }

    public override bool save() {
      // TODO (don't forget validation)
        bool isPrimary = (mailbox_address != null) && (mailbox_address.equal_to(account.primary_mailbox));
        Geary.RFC822.MailboxAddress new_mailbox = new Geary.RFC822.MailboxAddress(name_value.text, email_value.text);

        if (isPrimary) {
          // TODO handle primary inbox changing
            return false;
        } else {
            Gee.List<Geary.RFC822.MailboxAddress> mailboxes = account.alternate_mailboxes;

            // Don't allow a non-primary email address to be added/edited into the primary mailbox
            if (!isPrimary && new_mailbox.equal_to(account.primary_mailbox))
                return false;

            if (mailbox_address != null)
                mailboxes.remove(mailbox_address);

            mailboxes.add(new_mailbox);

            saved();

            return true;
        }
    }
}
