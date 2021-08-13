# zabbix-arris-tm1602
Zabbix template for monitoring [ARRIS TM1602 Cable Modems](https://arris.secure.force.com/consumers/ConsumerProductDetail?p=a0ha000000OlCnSAAV&c=Discontinued#panel3)


The default trigger values and graph limits are based on:
* [ARRIS SB6190: CABLE SIGNAL LEVELS](https://arris.secure.force.com/consumers/articles/General_FAQs/SB6190-Cable-Signal-Levels)
* [DSLReports Modems FAQ](http://www.dslreports.com/faq/16085)


## Dependencies
- curl
- gawk
- html-xml-utils (for hxnormalize)
- sed
- xmlstarlet
- pup
 
## Installation
- Copy the scripts to your Zabbix ExternalScripts location (default: /usr/lib/zabbix/externalscripts)
- Make sure the script permissions allow the zabbix server to execute them
- Import the template file into the Zabbix UI

## Setup and Configuration
- Create a new host "Cable Modem"
- Link the new host to the template
- If modem is not using 192.168.100.1 create a host macro {$MODEM_ADDRESS} to set a custom IP  address
- In Monitoring->Latest Data validate that the "Check Status" item has valid results

## What is Provided
Out of the box the template has a number of items, triggers, and graphs as well as discovery rules to provide individual channel details

### Template Items
* Check Status (5min refresh, text of status results)
  * ~~Boot (last value from config screen)
  * ~~Configuration (last value from config screen)
  * ~~Connectivity (last value from config screen)
  * Downsteam Channels (count)
  * Downstream Power (min/avg/max)
  * Downstream SNR (min/avg/max)
  * Downstream Corrected Errors (total accross all channels)
  * Downstream Uncorrectable Errors (total accross all channels)
  * Upstream Channels (count)
  * Upstream Power (min/avg/max)
  * Upstream Symbol Rate (min/avg/max)

* Ping (30sec refresh)
  * Simple up/down check
  * Response time

### Template Triggers
Trigger values are based on template macros so they can be overriden locally
* Downstream Channel MISSING 
* Downstream Power(avg) LOW
* Downstream Power(avg) HIGH
* Downstream SNR(avg) LOW
* Downstream Corrected Errors large increase
* Downstream Uncorrectable Errors large increase
* Upstream Channel MISSING 
* Upstream Power(avg) LOW
* Upstream Power(avg) HIGH   
* Ping HIGH LATENCY
* Ping offline

### Template Graphs
* Downstream Channels (count)
* Downstream Power
* Downstream SNR
* Corrected Errors
* Uncorrectable Errors
* Upstream Channels (count)
* Upstream Power
* Upstream Symbol Rate
* Ping Response Time

All 9 graphs are included on a monitoring screen as well


## Downstream Channel Discovery
Downstream channel discovery is run once a day and parses the status page information to create a list of channels. Each channel has items, triggers and graphs created.

### Downstream Channel Items
* Status
* Modulation (64QAM, 256QAM, etc)
* Frequency (MHz)
* Power (dBmV)
* SNR (dB)
* Corrected Errors
* Uncorrectable Errors

### Downstream Channel Triggers
Trigger values are based on template macros so they can be overriden locally
* Power LOW
* Power HIGH
* SNR LOW

### Downstream Channel Graphs
* Power
* SNR

## Upstream Channel Discovery
Upstream channel discovery is run once a day and parses the status page information to create a list of channels. Each channel has items, triggers and graphs created.

### Upstream Channel Items
* Status
* Channel Type (ATDMA, etc)
* Frequency (MHz)
* Power (dBmV)
* Symbol Rate (kSym/s) 

### Upstream Channel Triggers
Trigger values are based on template macros so they can be overriden locally
* Power LOW
* Power HIGH

### Upstream Channel Graphs
* Power
* Symbol Rate
