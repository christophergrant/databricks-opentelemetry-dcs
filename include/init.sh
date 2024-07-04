#!/bin/bash

/usr/bin/supervisord && supervisorctl start otelcol
