DynDNS script for InternetworX's XML-RPC API
=========
To execute the script simply adapt the variables in the CONFIG section (in inwx-dyndns.rb) and run

    ruby inwx-dyndns.rb


A logfile is automatically created and aged once it reaches a size of 1MB (up to 10 revisions of the file).


Run periodically
------
You may use cron to run the script periodically and update your dns entry.

Here is an example for running the script every 5 minutes:

    */5 * * * * cd ~/inwx-dyndns-ruby/; ruby inwx-dyndns.rb

See [the Arch Linux Wiki](https://wiki.archlinux.org/index.php/Crontab) for more information about cron.


License
----

MIT
