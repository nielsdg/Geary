/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

namespace Geary {

public abstract class Validator : Object {
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

    // All properties that should not be null.
    // TODO: I hoped this could be done in one property
    protected Object[] required_objects;
    protected string[] required_strings;

    public Validator() {
        // Just making sure required_properties is not null itself ^^
        required_objects = {};
        required_strings = {};
    }

    // Validate the given propertie(s) synchronously.
    public abstract async bool validate_async(Cancellable? cancellable);

    // The most basic validation: check if the required properties are not null.
    // Prevents you from writing a lot of null checks in subclasses.
    public bool check_required() {
        foreach (Object obj in required_objects) {
            if (obj == null) {
                // TODO: print out missing property.
                error_message = _("You did not fill in all required fields.");
                return false;
            }
        }
        foreach (string str in required_strings) {
            if (str == null) {
                // TODO: print out missing property.
                error_message = _("You did not fill in all required fields.");
                return false;
            }
        }

        error_message = "";
        return true;
    }

    // Fired as soon as the validation has failed, with the given error message.
    public signal void validation_done(bool success, string? error_message);
}

}

