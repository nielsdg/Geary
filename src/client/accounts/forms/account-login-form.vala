/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

[GtkTemplate (ui = "/org/gnome/Geary/account-login-form.ui")]
public class AccountLoginForm : ValidatedForm {
    // Username
    [GtkChild]
    private Gtk.Entry username_value;
    [GtkChild]
    private Gtk.Label username_validation_label;
    private Geary.EmailValidator username_validator;

    // Password
    [GtkChild]
    private Gtk.Entry password_value;
    [GtkChild]
    private Gtk.Label password_validation_label;
    private Geary.RequiredStringValidator password_validator;

    public AccountLoginForm() {
        username_validator = new Geary.EmailValidator();
        bind_validator(username_value, username_validator, "address");
        username_validator.validation_done.connect((succ) => {
            string label = (succ) ? "<span color=\"green\">✔</span>" : "<span color=\"red\">✗</span>";
            username_validation_label.label = label;
        });

        password_validator = new Geary.RequiredStringValidator(false);
        bind_validator(password_value, password_validator, "str");
        password_validator.validation_done.connect((succ) => {
            string label = (succ) ? "<span color=\"green\">✔</span>" : "<span color=\"red\">✗</span>";
            password_validation_label.label = label;
        });
    }
}
