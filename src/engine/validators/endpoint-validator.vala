/* Copyright 2016 Software Niels De Graef
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class Geary.EndpointValidator : Validator {

    private string remote_address;
    private int port;

    public EndpointValidator(string? remote_address, int port) {
        this.remote_address = remote_address;
        this.port = port;
    }

    public override async bool validate_async(Cancellable? cancellable) {
        // Check if the port is in a valid range
        if (port < 0 || port > 66535) {
            error_message = _("Invalid port: %d").printf(port);
            return false;
        }

        // Check if the remote_address and port are a valid endpoint
        string host_and_port = "%s:%d".printf(remote_address, port);
        try {
            NetworkAddress address = NetworkAddress.parse(host_and_port, 0);
            if (address == null) {
                error_message = _("Invalid address/port combination: %s").printf(host_and_port);
                return false;
            }
        } catch (Error e) {
            error_message = _("Invalid address/port combination: %s").printf(host_and_port);
            return false;
        }

        return true;
    }
}

