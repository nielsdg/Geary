/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class Geary.SmtpValidator : Validator {

    private Geary.Endpoint endpoint;
    private Geary.Credentials credentials;

    public SmtpValidator(Geary.Endpoint endpoint, Geary.Credentials? credentials) {
        this.endpoint = endpoint;
        this.credentials = credentials;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        // Check if login works (throws an SmtpError if not). Don't forget to log out afterwards
        Geary.Smtp.ClientSession? smtp_session = new Geary.Smtp.ClientSession(endpoint);
        try {
            yield smtp_session.login_async(credentials, cancellable);
        } catch (Error err) {
            error_message = _("Error logging into SMTP account: %s").printf(err.message);
            return false;
        }

        // Close connection
        try {
            yield smtp_session.logout_async(true, cancellable);
        } catch (Error err) {
            // ignored
        } finally {
            smtp_session = null;
        }

        error_message = "";
        return true;
    }
}

