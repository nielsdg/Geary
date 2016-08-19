/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
  * Validates an email address.
  * See: http://www.regular-expressions.info/email.html
  * matches john@dep.aol.museum not john@aol...com
  */
public class Geary.EmailValidator : Validator {

    private string? _address;
    public string? address {
      get {
        return _address;
      }
      set {
        _address = value;
        if (automatic_validation)
            validate_async.begin(null);
      }
    }

    public EmailValidator() {
    }

    public override async bool validate_async(Cancellable? cancellable) {
        try {
            Regex email_regex = new Regex("[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\\.)+[A-Z]{2,5}",
                RegexCompileFlags.CASELESS);

            if ((address == null) || (!email_regex.match(address))) {
                error_message = _("The given email is not valid.");
                return true;
            }

        } catch (RegexError e) {
            debug("Regex error in Geary.EmailValidator: %s", e.message);
        }

        error_message = "";
        return false;
    }
}

