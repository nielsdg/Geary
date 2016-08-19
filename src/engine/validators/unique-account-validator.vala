/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class Geary.UniqueAccountValidator : Validator {

    private Geary.AccountInformation account;
    private Gee.Collection<Geary.AccountInformation> other_accounts;
    private bool check_email_unique;

    public UniqueAccountValidator(Geary.AccountInformation account,
                                  Gee.Collection<Geary.AccountInformation> other_accounts,
                                  bool check_email_unique = false) {
        this.account = account;
        this.other_accounts = other_accounts;
        this.check_email_unique = check_email_unique;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        // Make sure the account nickname and email is not in use.
        foreach (AccountInformation a in other_accounts) {
            // Don't need to check a's alternate_emails since they
            // can't be set at account creation time
            if (account.has_email_address(a.primary_mailbox)) {
                if (this.check_email_unique) {
                    // Check for unique email address
                    error_message = _("Email address already exists in another account.");
                    return false;
                }
            } else {
                // Check for unique nickname
                if (Geary.String.stri_equal(account.nickname, a.nickname)) {
                    error_message = _("Invalid nickname.");
                    return false;
                }
            }

        }

        error_message = "";
        return true;
    }
}

