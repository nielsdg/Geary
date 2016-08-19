/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-imap-form.ui")]
public class AccountImapForm : AccountForm {
    [GtkChild]
    private Gtk.Grid category_general_grid;
    [GtkChild]
    private Gtk.Label service_provider_preconfigured;
    [GtkChild]
    private Gtk.Entry host_value;
    [GtkChild]
    private Gtk.SpinButton port_value;
    [GtkChild]
    private Gtk.Entry username_value;
    [GtkChild]
    private Gtk.Entry password_value;
    [GtkChild]
    private Gtk.CheckButton remember_password_check;
    [GtkChild]
    private Gtk.ComboBoxText encryption_combobox;
    [GtkChild]
    private Gtk.ComboBoxText download_mail_period_combobox;

    public AccountImapForm(Geary.AccountInformation account) {
        base(account, _("Receiving Mail Server"));

        // Fill in the data
        Geary.Endpoint endpoint = account.get_imap_endpoint();
        host_value.text = endpoint.remote_address.hostname;
        port_value.adjustment = new Gtk.Adjustment(endpoint.remote_address.port,
                                                   1.0, 4096.0, 1.0, 1.0, 1.0);
        encryption_combobox.active = endpoint.flags;

        if (account.service_provider == Geary.ServiceProvider.OTHER) {
            bind_validator(host_value, new Geary.RequiredStringValidator(true), "str");
            bind_validator(username_value, new Geary.RequiredStringValidator(true), "str");
            bind_validator(password_value, new Geary.RequiredStringValidator(true), "str");

            Geary.Credentials? credentials = account.imap_credentials;
            if (credentials.user != null)
                username_value.text = credentials.user;
            if (credentials.pass != null)
                password_value.text = credentials.pass;
            remember_password_check.active = account.imap_remember_password;
        } else { // Don't allow change of settings when it is a known (i.e. hardcoded) provider.
            service_provider_preconfigured.visible = true;
            category_general_grid.sensitive = false;
        }

        GtkUtil.set_combobox_separator(download_mail_period_combobox);
    }

    public override bool save() {
        //TODO

        return true;
    }
}
