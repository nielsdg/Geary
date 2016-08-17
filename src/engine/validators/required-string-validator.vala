/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class Geary.RequiredStringValidator : Validator {

    private string _str;
    public string str {
      get {
        return _str;
      }
      set {
        _str = value;
        validate_async.begin(null);
      }
    }

    private bool stripBlanks;

    public RequiredStringValidator(bool stripBlanks, string str = "") {
        this.str = str;
        this.stripBlanks = stripBlanks;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        if ((str == null) || (str == "") || (stripBlanks && str.strip() == "")) {
            error_message = _("A required field was left blank.");
            return false;
        }

        error_message = "";
        return true;
    }
}
