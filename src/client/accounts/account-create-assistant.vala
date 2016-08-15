/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/*
 * The AccountCreateAssistant consists of several AccountForms, each representing a page.
 */
[GtkTemplate (ui = "/org/gnome/Geary/account-create-assistant.ui")]
public class AccountCreateAssistant : Gtk.Assistant {
    private Geary.AccountInformation account;

    [GtkChild]
    private Gtk.ComboBoxText service_provider_combobox;

    public AccountCreateAssistant(Gtk.Window parent) {
        set_transient_for(parent);

        foreach (Geary.ServiceProvider p in Geary.ServiceProvider.get_providers())
            service_provider_combobox.append_text(p.display_name());
				service_provider_combobox.active = 0;

        try {
            account = Geary.Engine.instance.create_orphan_account();
						addAccountForm(new AccountImapForm(account));
						addAccountForm(new AccountSmtpForm(account));
						addAccountForm(new AccountSignatureForm(account));
        } catch(Error e) {
            debug(e.message);
            GearyApplication.instance.exit(1);
        }
    }

    public void addAccountForm(AccountForm form) {
        insert_page(form, get_n_pages() - 1);
        set_page_type(form, Gtk.AssistantPageType.CONTENT);
				set_page_title(form, form.title);
				set_page_complete(form, form.is_valid());
        form.valid.connect(() => set_page_complete(form, true));
    }
}

