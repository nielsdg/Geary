/* Copyright 2016 Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
 * Checks whether a (trimmed) string is non-blank.
 */
public class Geary.RequiredStringValidator : Validator {
    // The string to check
    private string _str;
    public string str {
      get {
        return _str;
      }
      set {
        _str = value;
        if (automatic_validation)
            validate_async.begin(null);
      }
    }

    // Whether to remove leading/trailing whitespace
    private bool strip_blanks;

    /**
     * Constructs a RequiredStringValidator
     * @param stripBlanks - Whether to check the string after leading/trailin whitespace is removed
     * @param label - The text of the accompanying label. This will be used to give a more
     *                specific error message.
     */
    public RequiredStringValidator(bool stripBlanks = true) {
        strip_blanks = stripBlanks;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        if ((str == null) || (str == "") || (strip_blanks && str.strip() == "")) {
            error_message = _("A required string was left blank");

            return false;
        }

        error_message = "";
        return true;
    }
}
