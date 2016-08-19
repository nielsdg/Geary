/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-signature-form.ui")]
public class AccountSignatureForm : AccountForm {

    [GtkChild]
    private Gtk.Stack view_stack;
    [GtkChild]
    private Gtk.Switch use_signature_switch;
    [GtkChild]
    private Gtk.TextView signature_text_view;
    [GtkChild]
    private Gtk.ScrolledWindow preview_window;

    private StylishWebView preview_webview;

    public AccountSignatureForm(Geary.AccountInformation account) {
        base(account, _("Signature"));

        use_signature_switch.active = account.use_email_signature;
        signature_text_view.buffer.text = account.email_signature;
        preview_webview = new StylishWebView();
        preview_webview.show();
        preview_window.add(preview_webview);

        view_stack.notify["visible-child-name"].connect(on_view_stack_changed);
    }

    private void on_view_stack_changed() {
        if (view_stack.visible_child_name == "preview_window")
            preview_webview.load_html_string(signature_text_view.buffer.text, "");
    }

    public override bool save() {
        account.use_email_signature = use_signature_switch.active;
        account.email_signature = signature_text_view.buffer.text;

        return true;
    }
}
