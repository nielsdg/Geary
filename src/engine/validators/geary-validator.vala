/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
 * A validator checks whether a condition holds for one or multiple properties.
 * Since it is a GLib.Object, you can use property binding to automate the verification.
 */
public abstract class Geary.Validator : Object {

    // Whether the validator should automatically validated on a property change
    public bool automatic_validation { get; set; default = true; }

    // Whether the last validation gave a successful result.
    public bool last_validation_result { get; set; }

    // The error message if the validation has failed.
    // Note: setting the error message triggers the validation_failed signal.
    public string error_message {
        get {
            return _error_message;
        }
        set {
            _error_message = value;
            last_validation_result = (value == "");
            validation_done(last_validation_result, _error_message);
        }
    }
    private string _error_message;

    public Validator() {
    }

    /**
     * Validates the given property/properties asynchronously.
     */
    public abstract async bool validate_async(Cancellable? cancellable);

    // Fired as soon as the validation has completed, with the given error message.
    public signal void validation_done(bool success, string? error_message);
}
