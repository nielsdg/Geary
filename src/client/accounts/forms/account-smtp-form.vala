/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-smtp-form.ui")]
public class AccountSmtpForm : AccountForm {
    [GtkChild]
    private Gtk.Grid category_general_grid;
    [GtkChild]
    private Gtk.Entry host_value;
    [GtkChild]
    private Gtk.SpinButton port_value;
    [GtkChild]
    private Gtk.ComboBoxText encryption_combobox;
    [GtkChild]
    private Gtk.RadioButton use_imap_credentials_check;
    [GtkChild]
    private Gtk.RadioButton use_custom_credentials_check;
    [GtkChild]
    private Gtk.Entry username_value;
    [GtkChild]
    private Gtk.Entry password_value;
    [GtkChild]
    private Gtk.CheckButton remember_password_check;
    [GtkChild]
    private Gtk.RadioButton no_credentials_check;
    [GtkChild]
    private Gtk.Switch save_sent_mail_switch;

    public AccountSmtpForm(Geary.AccountInformation account) {
        base(account, _("Sending Mail Server"));

        Geary.Endpoint endpoint = account.get_smtp_endpoint();
        host_value.text = endpoint.remote_address.hostname;
        port_value.value = endpoint.remote_address.port;
        encryption_combobox.active = endpoint.flags;

        if (account.service_provider == Geary.ServiceProvider.OTHER) {
            if (account.default_smtp_server_noauth) {
                no_credentials_check.active = true;
            } else if (account.default_smtp_use_imap_credentials) {
                use_imap_credentials_check.active = true;
            } else {  // Use custom credentials
                use_custom_credentials_check.active = true;
                Geary.Credentials? credentials = account.smtp_credentials;
                if (credentials != null) {
                    if (credentials.user != null)
                        username_value.text = credentials.user;
                    if (credentials.pass != null)
                        password_value.text = credentials.pass;
                    remember_password_check.active = account.smtp_remember_password;
                }
            }
        } else { // Don't allow change of settings when it is a known (i.e. hardcoded) provider.
            category_general_grid.foreach((widget) => {
                widget.sensitive = false;
            });
        }

        save_sent_mail_switch.active = account.save_sent_mail;
    }
}
