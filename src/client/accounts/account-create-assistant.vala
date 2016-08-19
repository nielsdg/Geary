/* Copyright 2016 Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
 * The AccountCreateAssistant consists of several AccountForms, each representing a page.
 */
[GtkTemplate (ui = "/org/gnome/Geary/account-create-assistant.ui")]
public class AccountCreateAssistant : Gtk.Assistant {
    private Geary.AccountInformation account;

    [GtkChild]
    private Gtk.ComboBoxText service_provider_combobox;
    [GtkChild]
    private Gtk.Box welcome_page;

    private AccountLoginForm loginForm;

    public AccountCreateAssistant(Gtk.Window parent) {
        Object(transient_for: parent);

        foreach (Geary.ServiceProvider p in Geary.ServiceProvider.get_providers())
            service_provider_combobox.append_text(p.display_name());
        service_provider_combobox.active = 0;

        // Add login form
        loginForm = new AccountLoginForm();
        welcome_page.pack_end(loginForm);
        set_page_complete(welcome_page, loginForm.is_valid());
        loginForm.validation_done.connect((succ) => set_page_complete(welcome_page, succ));
        set_page_type(welcome_page, Gtk.AssistantPageType.INTRO);

        try {
            account = Geary.Engine.instance.create_orphan_account();
            add_account_form(new AccountImapForm(account));
            add_account_form(new AccountSmtpForm(account));
            add_account_form(new AccountSignatureForm(account));
        } catch(Error e) {
            debug(e.message);
            GearyApplication.instance.exit(1);
        }

        // signals
        close.connect(() => {
            do_save_or_edit_async.begin();
            close();
        });
    }

    /**
     * Helper method, adds an account form to the assistent as a page.
     * @param form - The AccountForm that will become the new page
     */
    private void add_account_form(AccountForm form) {
        insert_page(form, get_n_pages() - 1);
        set_page_title(form, form.title);
        set_page_type(welcome_page, Gtk.AssistantPageType.CONTENT);
        set_page_complete(form, form.is_valid());
        form.validation_done.connect((succ) => set_page_complete(form, succ));
    }

    private async void do_save_or_edit_async() {
        Geary.Engine.ValidationOption options = Geary.Engine.ValidationOption.NONE;
        for (;;) {
            var validation_result = yield GearyApplication.instance.controller.validate_async(
                account, options);

            // check for TLS warnings
            bool retry_required;
            validation_result = yield GearyApplication.instance.controller.validation_check_for_tls_warnings_async(
                account, validation_result, out retry_required);
            if (!retry_required)
                break;
        }
    }
}

