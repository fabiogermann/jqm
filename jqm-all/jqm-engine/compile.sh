#!/bin/sh

mvn3 clean install -DskipTests dependency:copy-dependencies && cp target/jqm-engine-0.0.1-SNAPSHOT.jar ~/jqm/ && cp target/dependency/* ~/jqm/lib
