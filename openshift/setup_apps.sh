Openshift instructions:

# Set up Dev Project
oc new-project jtavares-dev --display-name="Dev Environment"

oc policy add-role-to-user edit system:serviceaccount:jtavares-jenkins:jenkins -n jtavares-dev

-----------

# Set up inbound Application
# Create Bc -> change the builder image
oc new-build --binary=true --name="inbound" jboss-eap71-openshift:1.3 -n jtavares-dev

#Create Dc
oc new-app jtavares-dev/inbound:0.0-0 --name=inbound --allow-missing-imagestream-tags=true -n jtavares-dev

# Remove automatic triggers
oc set triggers dc/inbound --remove-all -n jtavares-dev

# Expose Dc as a service and service as a route
oc expose dc inbound --port 9098 -n jtavares-dev
oc expose svc inbound -n jtavares-dev

# Set Probes
oc set probe dc/inbound -n jtavares-dev --readiness --failure-threshold 3 \
--initial-delay-seconds 60 --get-url=http://localhost:9098/cxf/demos/persons/something

--------------

# Set up outbound Application
# Create Bc -> change the builder image
oc new-build --binary=true --name="outbound" jboss-eap71-openshift:1.3 -n jtavares-dev

#Create Dc
oc new-app jtavares-dev/outbound:0.0-0 --name=outbound --allow-missing-imagestream-tags=true -n jtavares-dev

# Remove automatic triggers
oc set triggers dc/outbound --remove-all -n jtavares-dev

# Expose Dc as a service and service as a route
oc expose dc outbound --port 8080 -n jtavares-dev
oc expose svc outbound -n jtavares-dev

# Set Probes
oc set probe dc/outbound -n jtavares-dev --readiness --failure-threshold 3 \
--initial-delay-seconds 60 --get-url=http://:8080/

--------------

# Set up xlate Application
# Create Bc -> change the builder image
oc new-build --binary=true --name="xlate" jboss-eap71-openshift:1.3 -n jtavares-dev

#Create Dc
oc new-app jtavares-dev/xlate:0.0-0 --name=xlate --allow-missing-imagestream-tags=true -n jtavares-dev

# Remove automatic triggers
oc set triggers dc/xlate --remove-all -n jtavares-dev

# Expose Dc as a service and service as a route
oc expose dc xlate --port 8080 -n jtavares-dev
oc expose svc xlate -n jtavares-dev

# Set Probes
oc set probe dc/xlate -n jtavares-dev --readiness --failure-threshold 3 \
--initial-delay-seconds 60 --get-url=http://:8080/