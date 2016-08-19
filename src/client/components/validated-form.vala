/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
 * The ValidatedForm represents a form with fields that require validation.
 */
public abstract class ValidatedForm : Gtk.Box {

    // If this field is set, it will by default list the error messages from the validators.
    protected Gtk.Label error_label;

    // All active validators in this form
    protected Gee.Set<Geary.Validator> validators;

    public ValidatedForm() {
        validators = new Gee.HashSet<Geary.Validator>();
    }

    /**
     * This signal is fired if one of the validators has performed a validation.
     * @param success - Whether the form is valid.
     */
    public signal void validation_done(bool success);

    /**
     * Returns whether the form is complete and contains valid information. It does so by checking
     * each validator's last validation result. By default, it will set the error_label's text to
     * a list of all error messages.
     */
    public bool is_valid() {
        bool all_valid = true;

        if (error_label != null)
            error_label.label = "";

        // Aggregate error messages
        foreach (Geary.Validator validator in validators) {
            if (!validator.last_validation_result) {
                if (error_label != null && validator.error_message != null)
                    error_label.label += "- %s\n".printf(validator.error_message);
                all_valid = false;
            }
        }

        return all_valid;
    }

    public async bool validate_async(Cancellable? cancellable = null) {
        SourceFunc callb = validate_async.callback;
        int nr_validated = 0;
        foreach (Geary.Validator validator in validators) {
            validator.validate_async.begin(cancellable, () => {
                nr_validated++;
                if (nr_validated == validators.size) {
                    Idle.add((owned) callb);
                }
            });
        }

        yield;
        return is_valid();
    }

    /**
     * Helper method to bind an input GtkWidget to a certain validator. This allows for real-time validation.
     * @param formWidget - The widget that will contain the input, i.e. a Gtk.Entry or a Gtk.SpinButton
     * @param validator - The validator that will check the input of the input widget
     * @param property - The name of the validator's property (useful in cases a validator checks multiple properties)
     */
    protected void bind_validator(Gtk.Widget formWidget, Geary.Validator validator, string property) {
        validators.add(validator);
        validator.validation_done.connect((success, message) => {
            validation_done(is_valid());
        });

        if (formWidget is Gtk.Entry) formWidget.bind_property("text", validator, property);
        else if (formWidget is Gtk.SpinButton) formWidget.bind_property("value", validator, property);
    }
}
