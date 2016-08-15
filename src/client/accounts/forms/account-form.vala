/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
  * The AccountForm represents a part of the elements.
  */
public abstract class AccountForm : Gtk.Box {
    // The account for which the form is collecting information.
    protected Geary.AccountInformation account;

    // The title of the form
    private string _title;
    public string title {
      get { return _title; }
    }

    public AccountForm(Geary.AccountInformation account, string title) {
      this._title = title;
    }

    // This signal is fired if the form is complete and contains valid information.
    public signal void valid();

    // Whether the form is complete and contains valid information.
    public abstract bool is_valid();

    // Handler that should be called by each form element on change so we can fire the
    // 'valid'-signal at the appropriate time.
    protected void changed() {
        if (is_valid())
            valid();
    }
}
