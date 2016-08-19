/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class Geary.ImapValidator : Validator {

    private Geary.Endpoint endpoint;
    private Geary.Credentials credentials;

    public ImapValidator(Geary.Endpoint endpoint, Geary.Credentials credentials) {
        this.endpoint = endpoint;
        this.credentials = credentials;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        // validate IMAP, which requires logging in and establishing an AUTHORIZED cx state
        Geary.Imap.ClientSession? imap_session = new Imap.ClientSession(endpoint);
        try {
            yield imap_session.connect_async(cancellable);
        } catch (Error err) {
            error_message = _("Error connecting to IMAP server: %s").printf(err.message);
            return false;
        }

        try {
            yield imap_session.initiate_session_async(credentials, cancellable);

            // Connected and initiated, still need to be sure connection authorized
            Imap.MailboxSpecifier current_mailbox;
            if (imap_session.get_protocol_state(out current_mailbox) != Imap.ClientSession.ProtocolState.AUTHORIZED) {
                error_message = _("Wrong username/password.");
                return false;
            }
        } catch (Error err) {
            if (err is ImapError.UNAUTHENTICATED)
                error_message = _("Wrong username/password.");
            else
                error_message = _("Could not connect to IMAP server.");
            return false;
        }

        try {
            yield imap_session.disconnect_async(cancellable);
        } catch (Error err) {
            // ignored
        } finally {
            imap_session = null;
        }

        error_message = "";
        return true;
    }
}

