/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
  * The AccountForm represents a part of the account information's elements.
  */
public abstract class AccountForm : ValidatedForm {
    // The account for which the form is collecting information.
    protected Geary.AccountInformation? account;

    // The title of the form
    public string title { get; private set; }

    public AccountForm(Geary.AccountInformation? account, string title) {
        this.account = account;
        this.title = title;
    }

    /**
      * Saves the form information to the user account, iff it passes validation. If not, it will
      * return false.
      * NOTE: it saves to the object, so this is not persisted. Use account.store_async() for this.
      * @return Whether the form's inputs passed the validation (if not, it will not be saved).
      */
    public abstract bool save();
}
