/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
  * The ValidatedForm represents a form with fields that require validation.
  */
public abstract class ValidatedForm : Gtk.Box {

    // If this field is set, it will list the error messages from the validators.
    // Please set use_markup to true.
    protected Gtk.Label error_label;

    // All active validators in this form
    protected Gee.Set<Geary.Validator> validators;

    public ValidatedForm() {
        validators = new Gee.HashSet<Geary.Validator>();
    }

    // This signal is fired if the form is complete and contains valid information.
    public signal void validation_done(bool success);

    // Whether the form is complete and contains valid information.
    public bool is_valid() {
        bool all_valid = true;

        // Aggregate error messages
        if (error_label != null)
            error_label.label = "";
        foreach (Geary.Validator validator in validators) {
            if (!validator.last_validation_result) {
                if (error_label != null)
                    error_label.label += "- %s\n".printf(validator.error_message);
                all_valid = false;
            }
        }

        return all_valid;
    }

    protected void changed() {
        validation_done(is_valid());
    }

    // Helper method
    protected void bind_validator(Gtk.Widget formWidget, Geary.Validator validator, string property) {
        validators.add(validator);
        validator.validation_done.connect((success, message) => {
            if (is_valid()) {
                if (error_label != null)
                    error_label.set_label("");
            } else {
                if (error_label != null)
                    error_label.label = message;
            }
            changed();
        });

        if (formWidget is Gtk.Entry) formWidget.bind_property("text", validator, property);
        else if (formWidget is Gtk.SpinButton) formWidget.bind_property("value", validator, property);
    }
}
