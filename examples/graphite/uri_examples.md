Examples of URL for retrieving raw data from Graphite
=====================================================

Basic
-----
`http://monitoring.derecom.it/render/?target=frankenstein_derecom_it_collectd.interface.eth0.if_packets.rx&format=json`

Retrieve data from a relative time window
-----------------------------------------
`http://monitoring.derecom.it/render/?target=frankenstein_derecom_it_collectd.interface.eth0.if_packets.rx&format=json&from=-1hours`

Change resolution of x-axis
---------------------------
`http://monitoring.derecom.it/render/?target=summarize(nonNegativeDerivative(frankenstein_derecom_it_collectd.interface.eth0.if_packets.rx),"min","avg")&format=json&from=-1hours`
This will also make data retrieved more robust, since the summarize function
will get rid of eventual null values.

References
----------
 * https://answers.launchpad.net/graphite/+question/166935
