#!/bin/bash
service mysql restart && \
service apache2 restart && \
service zoneminder restart && \
tail -f /dev/null
