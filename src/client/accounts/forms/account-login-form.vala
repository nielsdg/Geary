/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-login-form.ui")]
public class AccountLoginForm : ValidatedForm {
    [GtkChild]
    private Gtk.Label validation_error_label;

    [GtkChild]
    private Gtk.Entry username_value;
    [GtkChild]
    private Gtk.Entry password_value;

    public AccountLoginForm() {
        base();

        error_label = validation_error_label;

        bind_validator(username_value, new Geary.RequiredStringValidator(true), "str");
        bind_validator(password_value, new Geary.RequiredStringValidator(true), "str");
    }
}
